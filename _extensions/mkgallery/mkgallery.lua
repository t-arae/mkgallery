
-- This function returns an iterator that traverses a table's elements
-- in the order of the table's keys, sorted by the optional comparison function f.
---@param t The table whose keys will be iterated.
---@param f (Optional) A comparison function to control the sorting order of the keys.
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

--- Parse keyword arguments
---@param kwargs A table containing key-value pairs of keyward arguments.
---@param logger A logger function.
---@return search_ext
---@return group 
---@return width
local function set_kwargs(kwargs, logger)
  -- Parse `ext` kwargs.
  -- If the key doesn't exist (i.e. ""), set the default value to 'png,jpeg,jpg'.
  local search_ext = pandoc.utils.stringify(kwargs["ext"])
  search_ext = search_ext ~= "" and search_ext or 'png,jpeg,jpg'
  logger("image ext: " .. search_ext)

  -- Parse `group` kwargs.
  -- If the key doesn't exist (i.e. ""), set the default value to 'all'.
  local group = pandoc.utils.stringify(kwargs["group"])
  group = group ~= "" and group or 'all'
  logger("group: " .. group)

  -- Parse `width` kwargs.
  -- If the key doesn't exist (i.e. ""), set the default value to 'calc(33% - 20px)'.
  local width = pandoc.utils.stringify(kwargs["width"])
  width = width ~= "" and width or 'calc(33% - 20px)'
  logger("width: " .. width)

  -- Return the final values for search_ext, group, and width.
  return search_ext, group, width
end

--- Parse positional arguments
---@param args A table containing positional arguments.
---@param wd A string representing the path to the working directory.
---@param logger A logger function.
---@return dir A string representing the image directory.
---@return gallery_type A string representing the gallery layout.
local function set_args(args, wd, logger)
  -- Get the number of arguments passed in the args table.
  local len_args = #args

  -- If at least one argument is provided, set the first argument to `dir`.
  -- And make the path relative to the `wd`.
  local dir = ""
  if len_args > 0 then
    dir = pandoc.path.make_relative(args[1], wd, true)
  end
  logger("image dir: " .. dir)

  -- If at least two argument is provided, set the second argument to `gallery_type`.
  -- If `gallery_type` is empty (or less than two argument are provided),
  -- then set a default value of 'scroll' to `gallery_type`.
  local gallery_type = ""
  if len_args > 1 then
    gallery_type = pandoc.utils.stringify(args[2])
  end
  gallery_type = gallery_type ~= "" and gallery_type or 'scroll'
  logger("gallery_type: " .. gallery_type)

  return dir, gallery_type
end

--- Search image files from directory.
---@param dir A string representing the image directory.
---@param search_ext A string representing the set of file extensions to search.
---@return files A table of files that matched the desired extensions.
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


local function build_img_block_wrap(images, group_id, width)
  local st = "flex: 0 0 " .. width .. "; max-width: " .. width .. ";"
  local blocks = {}
  for fname, img_path in pairsByKeys(images) do
    local image_block = pandoc.Div(
      {
        pandoc.Image({}, img_path, fname, {class = "lightbox", group = group_id}),
        pandoc.Div(fname, {id = fname, style = "overflow: hidden; text-overflow: ellipsis; max-width: 100%;"})
      },
      {style = st}
    )
    table.insert(blocks, image_block)
  end
  return pandoc.Div(blocks, {
    style = "display: flex; flex-wrap: wrap; gap: 20px; overflow-x: auto;"
  })
end

local function build_img_block_scroll(images, group_id, width)
  local st = "flex: 0 0 " .. width .. "; max-width: " .. width .. ";"
  local blocks = {}
  for fname, img_path in pairsByKeys(images) do
    local image_block = pandoc.Div(
      {
        pandoc.Image({}, img_path, fname, {class = "lightbox", group = group_id}),
        pandoc.Div(fname, {id = fname, style = "overflow: hidden; text-overflow: ellipsis; max-width: 100%;"})
      },
      {style = st}
    )
    table.insert(blocks, image_block)
  end
  return pandoc.Div(blocks, {
    style = "display: flex; gap: 20px; overflow-x: auto;"
  })
end

local function build_img_block_list(images, group_id, width)
  local st = "min-width " .. width .. "; max-width: " .. width .. ";"
  local blocks = {}
  for fname, img_path in pairsByKeys(images) do
    local image_block = pandoc.Div(
      {
        pandoc.Image({}, img_path, fname, {class = "lightbox", group = group_id}),
        pandoc.Div(fname, {id = fname, style = "overflow: hidden; text-overflow: ellipsis; max-width: 100%;"})
      },
      {style = st}
    )
    table.insert(blocks, image_block)
  end
  return pandoc.Div(blocks, {
    style = "overflow-x: auto;"
  })
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

    -- keyward args
    local search_ext, group_id, width = set_kwargs(kwargs, logger)
    -- args
    local dir, gallery_type = set_args(args, wd, logger)

    local files = search_img_files(dir, search_ext)

    if gallery_type == "scroll" then
      return build_img_block_scroll(files, group_id, width)
    elseif gallery_type == "wrap" then
      return build_img_block_wrap(files, group_id, width)
    elseif gallery_type == "list" then
      return build_img_block_list(files, group_id, width, hd_lev)
    else
      error()
    end
  end
}
