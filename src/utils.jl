module Utils

export pad_image, center_pixel_values, uncenter_pixel_values, image_to_blocks, blocks_to_image


function pad_image(img::Matrix{Float64})
    h, w = size(img)

    new_h = Int(ceil(h / 8) * 8)
    new_w = Int(ceil(w / 8) * 8)

    padded_img = zeros(Float64, new_h, new_w)
    padded_img[1:h, 1:w] = img

    return padded_img, (new_h, new_w)
end


function center_pixel_values(img)
    return img .- 128.0
end


function uncenter_pixel_values(img)
    return img .+ 128.0
end


function image_to_blocks(img, h, w)
    blocks = Vector{Matrix{Float64}}()

    for r in 1:8:h
        for c in 1:8:w
            block = img[r : r+7, c : c+7]
            push!(blocks, block)
        end
    end

    return blocks
end


function blocks_to_image(blocks, h, w)
    reconstructed_img = zeros(Float64, h, w)

    block_idx = 1

    for r in 1:8:h
        for c in 1:8:w
            reconstructed_img[r : r+7, c : c+7] = blocks[block_idx]
            block_idx += 1
        end
    end

    return reconstructed_img
end

end
