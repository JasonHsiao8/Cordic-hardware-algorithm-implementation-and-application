%==============================================================================
% Script: Simulation of Scaling Factor K value in CORDIC 
% Description: Computes CORDIC scaling factor K for hardware implementation
%              using Q1.14 fixed-point format with 16-bit word length
% Algorithm: Iterative computation of product of cos(arctan(2^-i))
% Format: Q1.14 (1 sign bit, 1 integer bit, 14 fractional bits)
% Author: Chia-Hung Hsiao
% Date: 2025/9/1
%==============================================================================

% Clear workspace and command window
clear;
clc;

%------------------------------------------------------------------------------
% CORDIC Configuration Parameters
%------------------------------------------------------------------------------
N_iter = 15;                % Number of CORDIC iterations (0 to 14)

%------------------------------------------------------------------------------
% CORDIC Scaling Factor Computation
% K = ∏(i=0 to N-1) cos(arctan(2^-i))
%   = ∏(i=0 to N-1) 1/√(1 + 2^(-2i))
%   ≈ 0.60725 for N → ∞
%
% This scaling factor compensates for the magnitude growth inherent in
% the CORDIC rotation algorithm. The final converged value approaches
% 0.607252935... as the number of iterations increases.
%------------------------------------------------------------------------------
K = 1;                      % Initialize scaling factor

% Iterative computation of scaling factor
for i = 0:N_iter-1
    K = K * (1 / sqrt(1 + 2^(-2*i)));
    fprintf('Iteration %2d: K = %.6f \n', i, K);
end

%------------------------------------------------------------------------------
% Final scaling factor K summary
%------------------------------------------------------------------------------
fprintf('\n');
fprintf('========================================\n');
fprintf('CORDIC Scaling Factor Summary\n');
fprintf('========================================\n');
fprintf('Number of iterations: %d\n', N_iter);
fprintf('Final K value:        %.6f\n', K);
fprintf('K in Q1.14 format:    %d (0x%04X)\n', round(K * 2^14), round(K * 2^14));
fprintf('========================================\n');