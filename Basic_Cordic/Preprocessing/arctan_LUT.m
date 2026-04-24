%==============================================================================
% Script: CORDIC Arctan Lookup Table Generator
% Description: Generates fixed-point arctan lookup table for CORDIC algorithm
%              with specified word length and fractional bits
% Output: Pre-computed arctan(2^-i) values in Q1.14 fixed-point format
% Usage: Values can be directly used in FPGA/ASIC CORDIC implementations
% Author: Chia-Hung Hsiao
% Date: 2025/9/1
%==============================================================================

% Clear workspace and command window
clear; clc;

%------------------------------------------------------------------------------
% CORDIC Fixed-Point Configuration
%------------------------------------------------------------------------------
N_iter = 15;                % Number of CORDIC iterations (generates 15 LUT entries)
WL = 16;                    % Word length (total bits including sign)
FL = 14;                    % Fractional length (number of fractional bits)
                            % Format: Q1.14 (1 sign, 1 integer, 14 fractional)

%------------------------------------------------------------------------------
% Fixed-Point Type Definition
% Defines the numeric representation for all fixed-point operations
%------------------------------------------------------------------------------
T = numerictype(1, WL, FL); % Signed fixed-point type
                            % Parameters: (signed, word_length, fraction_length)
                            % Range: [-2, 2) with 2^-14 precision

%------------------------------------------------------------------------------
% Fixed-Point Math Configuration
% Controls rounding and overflow behavior for arithmetic operations
%------------------------------------------------------------------------------
F = fimath(...
    'RoundingMethod', 'Nearest', ...      % Round to nearest (unbiased rounding)
    'OverflowAction', 'Saturate', ...     % Saturate on overflow (clip to max/min)
    'SumMode', 'KeepLSB', ...             % Keep LSB alignment for addition
    'SumWordLength', WL, ...              % Sum result uses same word length
    'ProductMode', 'KeepLSB', ...         % Keep LSB alignment for multiplication
    'ProductWordLength', WL);             % Product result uses same word length

%------------------------------------------------------------------------------
% Arctan Lookup Table Generation
% Pre-computes arctan(2^-i) for i = 0 to N_iter-1
% These values represent the rotation angles used in CORDIC iterations
%------------------------------------------------------------------------------
atan_table = fi(zeros(1, N_iter), T, F); % Initialize fixed-point array

fprintf('========================================\n');
fprintf('CORDIC Arctan Lookup Table (Q%d.%d)\n', WL-FL, FL);
fprintf('========================================\n');
fprintf('Index | Float Value  | Fixed (Dec) | Hex    | Degrees\n');
fprintf('------|--------------|-------------|--------|--------\n');

for i = 0:N_iter-1
    % Compute arctan(2^-i) in floating-point
    atan_float = atan(2^-i);
    
    % Convert to fixed-point with specified format
    atan_table(i+1) = fi(atan_float, T, F);
    
    % Extract fixed-point representations using storedInteger method
    atan_stored_int = storedInteger(atan_table(i+1));  % Get stored integer value
    atan_fixed_dec = int16(atan_stored_int);           % Convert to int16
    atan_uint = typecast(atan_fixed_dec, 'uint16');    % Typecast for hex display
    atan_fixed_hex = dec2hex(atan_uint, 4);            % Convert to hex string
    atan_degrees = atan_float * 180 / pi;              % Convert to degrees
    
    % Display table entry
    fprintf('%5d | %12.8f | %11d | 0x%s | %7.4f°\n', ...
        i, atan_float, atan_fixed_dec, atan_fixed_hex, atan_degrees);
end

fprintf('========================================\n');

%------------------------------------------------------------------------------
% Verilog/VHDL Code Generation
% Generate HDL-compatible initialization code
%------------------------------------------------------------------------------
fprintf('\n');
fprintf('HDL Initialization Code:\n');
fprintf('------------------------\n');
for i = 0:N_iter-1
    % Extract fixed-point value using storedInteger method
    atan_stored_int = storedInteger(atan_table(i+1));
    atan_int = int16(atan_stored_int);
    atan_uint = typecast(atan_int, 'uint16');
    atan_hex = dec2hex(atan_uint, 4);
    atan_deg = atan(2^-i) * 180 / pi;
    
    fprintf('atan_table[%2d] <= 16''sb%s;  // atan(2^-%d) ≈ %.4f°\n', ...
        i, atan_hex, i, atan_deg);
end
fprintf('------------------------\n');