using Images, FileIO

include("src/Transform.jl")
include("src/Quantization.jl")
include("src/Utils.jl")

using .Transform
using .Quantization
using .Utils


function run_jpeg_compression(input_path, output_path, resolution_scale)

    println("--- starting compression pipeline ---")

    println("1. loading image")

    img = load(input_path)
    img_gray = Gray.(img)

    img_matrix = Float64.(channelview(img_gray)) .* 255.0

    orig_h, orig_w = size(img_matrix)
    println("   Original Size: $orig_h x $orig_w")

    padded_img, (h, w) = Utils.pad_image(img_matrix)

    centered_img = Utils.center_pixel_values(padded_img)

    blocks = Utils.image_to_blocks(centered_img, h, w)
    println("   Sliced into $(length(blocks)) blocks of 8x8.")

    println("2. Compressing (DCT + Quantization)...")

    current_table = Quantization.scale_luminace_table(Quantization.LUMINANCE_TABLE, resolution_scale)
    compressed_blocks = []

    total_coefficients = 0
    zero_coefficients = 0

    for b in blocks
        freq_block = Transform.dct_2d(b)

        q_block = Quantization.quantize(freq_block, current_table)

        total_coefficients += 64
        zero_coefficients += count(x -> x == 0, q_block)

        push!(compressed_blocks, q_block)
    end

    zero_percentage = round((zero_coefficients / total_coefficients) * 100, digits=2)
    println("   Compression complete! $(zero_percentage)% of data is now Zero.")


    println("3. Decompressing (IDCT)...")

    reconstructed_blocks = []

    for b in compressed_blocks
        deq_block = Quantization.dequantize(b, current_table)
        pixel_block = Transform.idct_2d(deq_block)
        push!(reconstructed_blocks, pixel_block)
    end


    println("4. Stitching Image...")

    stitched_img = Utils.blocks_to_image(reconstructed_blocks, h, w)

    uncentered_img = Utils.uncenter_pixel_values(stitched_img)

    final_img_matrix = uncentered_img[1:orig_h, 1:orig_w]

    final_img_matrix = clamp.(final_img_matrix, 0.0, 255.0)

    final_image_obj = Gray.(final_img_matrix ./ 255.0)

    save(output_path, final_image_obj)
    println("--- Done! Saved to $output_path ---")
end


run_jpeg_compression("data/input/test_1.jpg", "data/output/test_1_compressed.jpg", 5)
