return {
  ['mkgallery'] = function(args, kwargs, meta) 
    local dir = args[1]
    local files = pandoc.system.list_directory(dir)
    for k, v in pairs(files) do
      files[k] = pandoc.path.join({dir, v})
    end

    local function insert_image_blocks(images)
      local blocks = {}
      for _, img_path in ipairs(images) do
        local image_block = pandoc.Para({pandoc.Image({}, img_path)})
        table.insert(blocks, image_block)
      end
      return blocks
    end

    return insert_image_blocks(files)
  end
}
