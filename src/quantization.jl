module Quantization

export luminace_table_clamp_scale, scale_luminace_table, quantize, dequantize, LUMINANCE_TABLE, CHROMINANCE_TABLE

LUMINANCE_TABLE = [
    16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99
]

CHROMINANCE_TABLE = [
    17 18 24 47 99 99 99 99;
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99
]

function luminace_table_clamp_scale(value, scale)
    return max(min(value*scale, 255), 0)
end

function scale_luminace_table(table, scale)
    return luminace_table_clamp_scale.(table, scale)
end

function quantize(dct_block, table)
    quant_block = dct_block ./ table
    return Int.(round.(quant_block))
end

function dequantize(quant_block, table)
    dct_block = quant_block .* table
    return Float64.(dct_block)
end

end
