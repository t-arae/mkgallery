
function pairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
end

function set_kwargs(kwargs, logger)
  local search_ext = pandoc.utils.stringify(kwargs["ext"])
  search_ext = search_ext ~= "" and search_ext or 'png,jpeg,jpg'
  logger("image ext: " .. search_ext)

  local group = pandoc.utils.stringify(kwargs["group"])
  group = group ~= "" and group or 'all'
  logger("group: " .. group)

  local min_width = pandoc.utils.stringify(kwargs["min-width"])
  --min_width = min_width ~= "" and min_width or '240px'
  min_width = min_width ~= "" and min_width or '200px'
  logger("min_width: " .. min_width)

  local hd_lev = pandoc.utils.stringify(kwargs["hd_lev"])
  hd_lev = hd_lev ~= "" and (hd_lev + 0) or 2
  logger("header level: " .. hd_lev)

  return search_ext, group, min_width, hd_lev
end

function set_args(args, wd, logger)
    local len_args = #args

    local dir = ""
    if len_args > 0 then
      dir = pandoc.path.make_relative(args[1], wd, true)
    end
    logger("image dir: " .. dir)

    local gallery_type = ""
    if len_args > 1 then
      gallery_type = pandoc.utils.stringify(args[2])
    end
    gallery_type = gallery_type ~= "" and gallery_type or 'scroll'
    logger("gallery_type: " .. gallery_type)

    return dir, gallery_type
end

function search_img_files(dir, search_ext)
    local lpeg = require"lpeg"
    -- Make file extension pattern
    local i = true
    for n in search_ext:gmatch("[%a%d]+") do
      if i then
        pat_ext = lpeg.P(n)
        i = false
      else
        pat_ext = pat_ext + lpeg.P(n)
      end
    end 
    local cap_ext = lpeg.C(pat_ext)
    local pat = "." * cap_ext * -1

    local files = {}
    for _, v in ipairs(pandoc.system.list_directory(dir)) do
      local stem, ext = pandoc.path.split_extension(v)

      if pat:match(ext) then
        --print("matched: " .. ext)
        files[v] = pandoc.path.join({dir, v})
      else
        --print("mis-matched: " .. ext)
        files[v] = nil
      end
    end

    return files
end

function build_img_block_wrap(images, group_id, min_width, hd_lev)
  local st = "flex-grow: 1; min-width: " .. min_width .. "; max-width: calc(30% - 20px);"
  local blocks = {}
  for fname, img_path in pairsByKeys(images) do
    local image_block = pandoc.Div({
      pandoc.Header(hd_lev, fname, {id = fname}),
      pandoc.Div(
          pandoc.Image({}, img_path, fname, {class = "lightbox", group = group_id})
        )},
      {style = st}
    )
    table.insert(blocks, image_block)
  end
  return pandoc.Div(blocks, {
    style = "display: flex; flex-wrap: wrap; gap: 20px; overflow-x: auto;"
  })
end

local function build_img_block_scroll(images, group_id, min_width, hd_lev)
  local st = "flex-grow: 1; min-width: " .. min_width .. "; max-width: calc(50% - 20px);"
  local blocks = {}
  for fname, img_path in pairsByKeys(images) do
    local image_block = pandoc.Div({
      pandoc.Header(hd_lev, fname, {id = fname}),
      pandoc.Div(
        pandoc.Image({}, img_path, fname, {
          class = "lightbox",
          group = group_id
        }),
        {style = st}
      )
    })
    table.insert(blocks, image_block)
  end
  return pandoc.Div(blocks, {
    style = "display: flex; gap: 20px; overflow-x: auto;"
  })
end

local function build_img_block_list(images, group_id, min_width, hd_lev)
  local st = "min-width: " .. min_width .. "; max-width: calc(50% - 20px);"
  local blocks = {}
  for fname, img_path in pairsByKeys(images) do
    local image_block = pandoc.Div({
      pandoc.Header(hd_lev, fname, {id = fname}),
      pandoc.Div(
        pandoc.Image({}, img_path, fname, {
          class = "lightbox",
          group = group_id
        }),
        {style = st}
      )
    })
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
    local search_ext, group_id, min_width, hd_lev = set_kwargs(kwargs, logger)
    -- args
    local dir, gallery_type = set_args(args, wd, logger)

    local files = search_img_files(dir, search_ext)

    if gallery_type == "scroll" then
      return build_img_block_scroll(files, group_id, min_width, hd_lev)
    elseif gallery_type == "wrap" then
      return build_img_block_wrap(files, group_id, min_width, hd_lev)
    elseif gallery_type == "list" then
      return build_img_block_list(files, group_id, min_width, hd_lev)
    else
      error()
    end
  end
}
