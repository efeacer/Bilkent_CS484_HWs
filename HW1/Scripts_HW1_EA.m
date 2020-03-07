% CS484 - Script for Homework 1
% Author: EFE ACER

close all;
clear all;

%% Question 1: Results

image_1a = imread('1a.png');
image_1b = rgb2gray(imread('1b.png'));

histogram(image_1a);
histogram(image_1b);

%% Question 2: Results

image_2a = imread('2a.png');
image_2b = imread('2b.png'); 

binary_image_2a = otsu_threshold(image_2a);
figure;
imshow(binary_image_2a);
binary_image_2b = otsu_threshold(image_2b);
figure;
imshow(binary_image_2b);

%% Question 4: Results

% Read image 3(a)
image_3a = rgb2gray(imread('3a.png'));

% Apply thresholding and reversal
binary_image_3a = ~otsu_threshold(image_3a);

% Structuring element definitions 

s = logical([
    1 0 1;
    0 1 0;
    1 0 1]);

s_ = logical([
    1 0 0 0 1;
    0 1 0 1 0;
    0 0 1 0 0;
    0 1 0 1 0;
    1 0 0 0 1]);

left_s = logical([
    1 1 1 1 1 0 0 0 0 0;
    1 1 1 1 1 0 0 0 0 0]);

left_s1 = logical([
    1 1 1 1 1 0 0 0 0 0]);

% Apply morphological operations
result_3a = binary_image_3a;
result_3a = erosion(result_3a, ones(5, 3));
result_3a = erosion(result_3a, ones(5, 3));
result_3a = erosion(result_3a, ones(5, 3));
result_3a = erosion(result_3a, ones(5, 3));
result_3a = dilation(result_3a, ones(7, 7));
result_3a = dilation(result_3a, ones(5, 5));
result_3a = dilation(result_3a, ones(5, 5));
result_3a = dilation(result_3a, left_s);
result_3a = dilation(result_3a, left_s);
result_3a = dilation(result_3a, left_s);
result_3a = dilation(result_3a, left_s1);
result_3a = dilation(result_3a, left_s1);
result_3a = result_3a & opening(closing(binary_image_3a, s_), s); 

% Perform connected component labeling
[L, n] = bwlabel(result_3a);
fprintf("Number of labeled components (image 3(a)): %d\n", n);
colored_3a = label2rgb(L, 'hsv', 'k', 'shuffle');

figure;
imshow(binary_image_3a);
figure;
imshow(result_3a);
figure;
imshow(colored_3a);

% Read image 3(b)
image_3b = imread('3b.png');

% Apply thresholding 
binary_image_3b = otsu_threshold(image_3b);

% Structuring element definitions 

diag1 = logical([
    1 0 0 0 0;
    0 1 0 0 0;
    0 0 1 0 0;
    0 0 0 1 0;
    0 0 0 0 1]);

diag2 = logical([
    0 0 0 0 0 0 1;
    0 0 0 0 0 1 0;
    0 0 0 0 1 0 0;
    0 0 0 1 0 0 0;
    0 0 1 0 0 0 0;
    0 1 0 0 0 0 0;
    1 0 0 0 0 0 0]);

% Apply morphological operations
result_3b = binary_image_3b;
result_3b = erosion(result_3b, diag2);
result_3b = closing(result_3b, ones(5, 5));
result_3b = erosion(result_3b, diag1);
result_3b = dilation(result_3b, diag2);
result_3b = dilation(result_3b, ones(5, 5));
result_3b = dilation(result_3b, ones(5, 5));
result_3b = closing(result_3b, ones(5, 5));
result_3b = dilation(result_3b, diag2);

% Perform connected component labeling
[L, n] = bwlabel(result_3b);
fprintf("Number of labeled components (image 3(b)): %d\n", n);
colored_3b = label2rgb(L, 'hsv', 'k', 'shuffle');

figure;
imshow(binary_image_3b);
figure;
imshow(result_3b);
figure;
imshow(colored_3b);

%% Question 1: Functions

% count_occurrences: Given a grayscale image I, this function returns a 
% histogram h, which is an array storing the occurrence count of each 
% gray tone (from 0 to 255) in the image. 
function h = count_occurrences(I)
    h = zeros(1, 256, 'uint32');
    [num_rows, num_cols] = size(I);
    for i = 1:num_rows
        for j = 1:num_cols
            intensity = I(i, j) + 1; % +1 is for proper indexing
            h(intensity) = h(intensity) + 1;
        end
    end
end

% format_histogram: This function draws some GUI details on top of the 
% figure containing the histogram. These details include titles, labels and 
% a gray colorbar. The code is separated from the actual histogram function
% to make it look cleaner.
function format_histogram()
    grid;
    ax = gca;
    set(ax, 'XLim', [0 255], 'XTickLabel', [], 'Box', 'on');
    
    % Create an additional axes and draw the grayscale colorbar
    ax2 = axes('Position', get(ax, 'Position'), 'HitTest', 'off');
    image(0:255, [0 1], repmat(gray', 1, 1, 3), 'Parent', ax2);
    set(ax2, 'XLim', [0 255], 'YLim', [0, 1], 'YTick', [], 'Box', 'on');
    
    % Open up space for the colorbar 
    set(ax, 'Units', 'pixels');
    pos = get(ax, 'Position');
    set(ax, 'Position', [pos(1), pos(2) + 25, pos(3), pos(4) - 25]);
    set(ax, 'Units', 'normalized');
    
    % Put the colorbar at the space opened up above
    set(ax2, 'Units', 'pixels');
    pos = get(ax2, 'Position');
    set(ax2, 'Position', [pos(1:3), 25]);
    set(ax2, 'Units', 'normalized');
    
    % Draw the title and axes labels
    xlabel('Gray Intensity');
    % Link the axes together 
    linkaxes([ax ax2], 'x');
    set(ancestor(ax, 'figure'), 'CurrentAxes', ax);
    title('Image Histogram');
    ylabel('Frequency (Occurrence Count)');
end

% histogram: Given a grayscale source image, displays the corresponding 
% image histogram.
function histogram(source_image)
    % Store the number of pixels corresponding to each gray intensity in h
    h = count_occurrences(source_image);
    % Plot the bar chart displaying the occurrence counts (i.e. histogram)
    figure;
    bar(0:255, h);
    format_histogram(); % Draws the GUI details of the histogram 
end

%% Question 2: Functions

% histogram: Given a grayscale source image, applies automatic otsu
% thresholding to generate a binary output
function binary_image = otsu_threshold(source_image) 
    % Obtain the frequency distribution
    h = double(count_occurrences(source_image));
    total_sum = dot(0:255, h); % total sum of gray intensities 
    num_pixels = sum(h);
    
    % Initialization
    w1 = 0; % weight (number of pixels) of the first cluster
    sum1 = 0; % sum of gray intensities in the first cluster
    
    % Iterate all values to search for the maximizing t
    t = 0; 
    max_var = -inf;
    for i = 1:255
        % Recursively update the weights and the centers
        w1 = w1 + h(i);
        sum1 = sum1 + (i - 1) * h(i);
        mu1 = sum1 / w1;
        mu2 = (total_sum - sum1) / (num_pixels - w1);
        % Calculate the between-group variance
        var = w1 * (num_pixels - w1) * (mu1 - mu2)^2;
        % Update maximizing t if necessary
        if var > max_var
            t = i - 1;
            max_var = var;
        end
    end
    fprintf('Maximing t = %d\n', t); % To see the optimal threshold
    
    % Apply threshold above operation using the maximizer t
    binary_image = source_image >= t;
end

%% Question 3: Functions

% dilation: Given a binary source image and a binary structuring element,
% applies dilation to the image to enlarge the object boundaries.
function dilated_image = dilation(source_image, struct_el)
    % Get the necessary dimension information and compute padding values
    [height_s, width_s] = size(struct_el);
    pad_x = floor(width_s / 2);
    pad_y = floor(height_s / 2);
    
    % Apply 0 padding to the original image
    I = padarray(source_image, [pad_y, pad_x]);
    
    % Find indices of 1's
    [row, col] = find(I == 1);
    
    dilated_image = false(size(I));
 
    for i = 1:length(row)
        x_begin = col(i) - pad_x;
        x_end = x_begin + width_s - 1;
        y_begin = row(i) - pad_y;
        y_end = y_begin + height_s - 1;
        % There must be at least one 1 in the overlapping section
        if nnz(I(y_begin:y_end, x_begin:x_end) & struct_el) > 0
            % Fill the neighborhood by or'ing with struct_el
            dilated_image(y_begin:y_end, x_begin:x_end) = ...
                dilated_image(y_begin:y_end, x_begin:x_end) | struct_el;
        end
    end
    
    % Remove padding
    dilated_image = dilated_image((pad_y + 1):(end - pad_y), ...
        (pad_x + 1):(end - pad_x));
end

% erosion: Given a binary source image and a binary structuring element,
% applies erosion to the image to shrink the object boundaries.
function eroded_image = erosion(source_image, struct_el)
    % Get the necessary dimension information and compute padding values
    [height_i, width_i] = size(source_image);
    [height_s, width_s] = size(struct_el);
    pad_x = floor(width_s / 2);
    pad_y = floor(height_s / 2);
    
    % Apply 0 padding to the original image
    I = padarray(source_image, [pad_y, pad_x]);
    
    % Find indices of 1's
    [row, col] = find(I == 1);
    
    % Find number of 1's in the structuring element
    nnz_s = nnz(struct_el);
    
    eroded_image = false(height_i, width_i);
    
    for i = 1:length(row)
        x_begin = col(i) - pad_x;
        x_end = x_begin + width_s - 1;
        y_begin = row(i) - pad_y;
        y_end = y_begin + height_s - 1;
        % Number of 1's in the and result must equal that of the struct_el 
        if nnz(I(y_begin:y_end, x_begin:x_end) & struct_el) == nnz_s
            eroded_image(y_begin, x_begin) = ...
                eroded_image(y_begin, x_begin) | ...
                struct_el(1 + pad_y, 1 + pad_x);
        end
    end
end

%% Question 4: Functions

function closed_image = closing(source_image, struct_el)
    closed_image = erosion(dilation(source_image, struct_el), struct_el);
end

function opened_image = opening(source_image, struct_el)
    opened_image = dilation(erosion(source_image, struct_el), struct_el);
end