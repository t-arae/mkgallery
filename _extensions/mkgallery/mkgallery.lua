return {
  ['mkgallery'] = function(args, kwargs, meta) 
    local lpeg = require"lpeg"
    local wd = pandoc.system.get_working_directory()

    local search_ext = pandoc.utils.stringify(kwargs["ext"])
    search_ext = search_ext ~= "" and search_ext or 'png,jpeg,jpg'
    print("image ext: " .. search_ext)

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

    local hd_lev = pandoc.utils.stringify(kwargs["hd_lev"])
    hd_lev = hd_lev ~= "" and (hd_lev + 0) or 2
    print("header level: " .. hd_lev)

    local dir = pandoc.path.make_relative(args[1], wd, true)
    print("working dir: " .. wd)
    print("image dir: " .. dir)

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

    local function insert_image_blocks(images)
      local blocks = {}
      for fname, img_path in pairs(images) do
        print(fname)
        local image_block = pandoc.Div({pandoc.Header(hd_lev, fname, {id = fname}), pandoc.Image({}, img_path)})
        table.insert(blocks, image_block)
      end
      return blocks
    end

    return insert_image_blocks(files)
  end
}
