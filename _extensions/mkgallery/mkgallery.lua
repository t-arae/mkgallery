
-- This function returns an iterator that traverses a table's elements
-- in the order of the table's keys, sorted by the optional comparison function f.
---@param t table The table whose keys will be iterated.
---@param f? function (Optional) A comparison function to control the sorting order of the keys.
local function pairsByKeys(t, f)
  -- Create an empty array to store the table's keys.
  -- Insert all keys from the table t into the array a.
  -- Sort the keys in array a. If a function f is provided, use it for sorting.
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  
  -- Define an iterator function that returns the next key-value pair in sorted order.
  local i = 0
  local iter = function () 
    i = i + 1
    -- If there are no more keys, return nil to end the iteration.
    if a[i] == nil then 
      return nil
    else 
      -- Otherwise, return the next key and its corresponding value from the table.
      return a[i], t[a[i]]
    end
  end
  
  -- Return the iterator, which can be used to traverse the sorted keys.
  return iter
end

local function get_arg_value(args_table, key, default)
  local value = pandoc.utils.stringify(args_table[key] or "")
  return value ~= "" and value or default
end

--- Parse keyword arguments
---@param kwargs table A table containing key-value pairs of keyward arguments.
---@param logger function A logger function.
---@return string search_ext
---@return string group 
---@return string width
---@return string height
local function parse_kwargs(kwargs, logger)
  -- Parse `ext` kwargs. (default: "png,jpeg,jpg")
  local search_ext = get_arg_value(kwargs, "ext", "png,jpeg,jpg")
  logger("image ext: " .. search_ext)

  -- Parse `group` kwargs. (default: "all")
  local group = get_arg_value(kwargs, "group", "all")
  logger("group: " .. group)

  -- Parse `width` kwargs. (default: "calc(33% - 20px)")
  local width = get_arg_value(kwargs, "width", "calc(33% - 20px)")
  logger("width: " .. width)

  -- Parse `height` kwargs. (default: "")
  local height = get_arg_value(kwargs, "height", "")
  logger("height: " .. height)

  -- Return the final values for search_ext, group, and width.
  return search_ext, group, width, height
end

--- Parse positional arguments
---@param args table A table containing positional arguments.
---@param wd string A string representing the path to the working directory.
---@param logger function A logger function.
---@return string dir A string representing the image directory.
---@return string gallery_type A string representing the gallery layout.
local function parse_args(args, wd, logger)
  -- Set the first argument to `dir`, and make the path relative to the `wd`.
  local dir = ""
  if #args > 0 then
    dir = pandoc.path.make_relative(args[1], wd, true)
  end
  logger("image dir: " .. dir)

  -- Set the second argument to `gallery_type`. (default: "scroll")
  local gallery_type = get_arg_value(args, 2, "scroll")
  logger("gallery_type: " .. gallery_type)

  return dir, gallery_type
end

--- Search image files from directory.
---@param dir string A string representing the image directory.
---@param search_ext string A string representing the set of file extensions to search.
---@return table files A table of files that matched the desired extensions.
local function search_img_files(dir, search_ext)
  -- Import the LPeg library, which is used for pattern matching.
  local lpeg = require"lpeg"
  
  -- Create a pattern for matching file extensions using LPeg.
  local i = true  -- Flag to check if it's the first extension being processed.
  
  -- Loop through the search_ext string and extract individual extensions.
  for n in search_ext:gmatch("[%a%d]+") do
    if i then
      -- If this is the first extension, initialize the pattern.
      pat_ext = lpeg.P(n)
      i = false
    else
      -- For subsequent extensions, add them to the existing pattern.
      pat_ext = pat_ext + lpeg.P(n)
    end
  end 
  
  -- Capture the extension pattern.
  local cap_ext = lpeg.C(pat_ext)
  -- Create a pattern that looks for extensions at the end of the filename.
  local pat = "." * cap_ext * -1

  -- Initialize an empty table to store matching image files.
  local files = {}
  
  -- Loop through all files in the directory.
  for _, v in ipairs(pandoc.system.list_directory(dir)) do
    -- Split the file name into its stem (base name) and extension.
    local stem, ext = pandoc.path.split_extension(v)

    -- Check if the file's extension matches the desired pattern.
    if pat:match(ext) then
      -- If it matches, store the full path of the file in the files table.
      files[v] = pandoc.path.join({dir, v})
    else
      -- If it doesn't match, exclude the file by setting the entry to nil.
      files[v] = nil
    end
  end

  -- Return the table of files that matched the desired extensions.
  return files
end


local function build_style(properties)
  local style = ""
  for property, value in pairsByKeys(properties) do
    style = style .. string.format(" %s: %s;", property, value)
  end
  return style
end

local function create_attrs(is_img, additional_classes, styles)
  --local classes = is_img and {"lightbox", "border"} or {"border"}
  local classes = is_img and {"lightbox"} or {}
  if additional_classes then
    for _, class in ipairs(additional_classes) do
      table.insert(classes, class)
    end
  end
  return pandoc.Attr("", classes, {style = styles})
end

local function build_gallery(images, group_id, width, height, gallery_type)
  local gallery_styles = { ["overflow-x"] = "auto" }
  if gallery_type == "scroll" or gallery_type == "wrap" then
    gallery_styles["display"] = "flex"
    gallery_styles["gap"] = "20px"
  end
  if gallery_type == "wrap" then
    gallery_styles["flex-wrap"] = "wrap"
  end
  local gallery_attr = create_attrs(false, nil, build_style(gallery_styles))

  local img_styles = {
    ["width"] = "100%",
    ["object-fit"] = "contain"
  }
  if height ~= "" then
    img_styles["height"] = height
    img_styles["width"] = nil
  end
  local img_attr = create_attrs(true, nil, build_style(img_styles))
  img_attr.attributes.group = group_id

  local block_styles = {["flex"] = "none"}
  if width ~= "" then
    block_styles["width"] = width
    block_styles["display"] = "flex"
    block_styles["flex-direction"] = "column"
  end
  local block_attr = create_attrs(false, nil, build_style(block_styles))

  local name_attr = create_attrs(false, nil, "overflow: hidden; text-overflow: ellipsis; max-width: 100%; margin-top: auto;")

  local blocks = {}
  for fname, img_path in pairsByKeys(images) do
    local image_block = pandoc.Div(
      {
        pandoc.Image({fname}, img_path, fname, img_attr),
        pandoc.Div(fname, name_attr)
      },
      block_attr
    )
    table.insert(blocks, image_block)
  end

  return pandoc.Div(blocks, gallery_attr)
end

return {
  ['mkgallery'] = function(args, kwargs, meta) 
    
    local logger = function(x)
      if false then
        print(x)
      end
    end

    local wd = pandoc.system.get_working_directory()
    logger("working dir: " .. wd)

    -- Parse args and keyward args
    local dir, gallery_type = parse_args(args, wd, logger)
    local search_ext, group_id, width, height = parse_kwargs(kwargs, logger)

    local files = search_img_files(dir, search_ext)

    return build_gallery(files, group_id, width, height, gallery_type)
  end
}
