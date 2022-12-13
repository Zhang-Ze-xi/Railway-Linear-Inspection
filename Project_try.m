clc;
clear;
close all;
% 问题描述
% 本题目中，我们需要对铁路线进行寻线，并提取轨道线
% 本问题根本目的在于通过图形变换，将视角中的铁路线
% 转换为直线，然后提取出轨道线
% 首先我们选定图像中的感兴趣区域，然后对其进行灰度变换
% 之后，我们对其进行二值化处理，然后进行形态学处理
% 最后，我们对其进行霍夫变换，提取出轨道线
% 导入图像
img = imread('F:\VS Code\Matlab\Project\Project1\text.jpg');
figure(1);
imshow(img);
title('原图像');
% 测量图像大小
[height, width, channel] = size(img); % height为图像高度，width为图像宽度，channel为图像通道数
% 选定感兴趣区域
img1 = img(1:132, 1:359, :) ; % img1为感兴趣区域，img(1:height, 1:width, :);
figure(2);
imshow(img1);
title('感兴趣区域');
% 测量当前感兴趣区域大小
[height1, width1, channel1] = size(img1);
% 灰度变换将绿色区域转换为黑色
img2 = rgb2gray(img1);
figure(3);
imshow(img2);
title('灰度变换');
% 提高对比度
img3 = imadjust(img2);
figure(4);
imshow(img3);
title('提高对比度');
% 中值滤波
img4 = medfilt2(img3);
figure(5);
imshow(img4);
title('中值滤波');
% 高斯滤波
img5 = imgaussfilt(img4, 1);
figure(6);
imshow(img5);
title('高斯滤波');
% Canny边缘检测
img6 = edge(img5, 'Canny');
figure(7);
imshow(img6);
title('Canny边缘检测');
% Hough变换直线检测
[H, theta, rho] = hough(img6);
figure(8);
imshow(imadjust(mat2gray(H)), 'XData', theta, 'YData', rho, 'InitialMagnification', 'fit');
xlabel('\theta (degrees)');
ylabel('\rho');
axis on;
axis normal;
hold on;
colormap(gca, hot);
P = houghpeaks(H, 5, 'threshold', ceil(0.3*max(H(:))));
x = theta(P(:,2));
y = rho(P(:,1));
plot(x, y, 's', 'color', 'black');
lines = houghlines(img6, theta, rho, P, 'FillGap', 5, 'MinLength', 7);
figure(9);
imshow(img6);
hold on;
% 绘制直线并确定最长的线段
max_len = 0;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'yellow'); % 绘制线段黄色为疑似结果
    % 绘制线条的起点和终点
    plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'green');
    plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'green');
    % 确定最长线段的端点
    len = norm(lines(k).point1 - lines(k).point2);
    if ( len > max_len)
        max_len = len;
        xy_long = xy;
    end
end
% 确定第二长的线段
max_len1 = 0;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    len = norm(lines(k).point1 - lines(k).point2);
    if ( len > max_len1 && len < max_len)
        max_len1 = len;
        xy_long1 = xy;
    end
end
% 确定第三长的线段
max_len2 = 0;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    len = norm(lines(k).point1 - lines(k).point2);
    if ( len > max_len2 && len < max_len1)
        max_len2 = len;
        xy_long2 = xy;
    end
end
% 确定第四长的线段
max_len3 = 0;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    len = norm(lines(k).point1 - lines(k).point2);
    if ( len > max_len3 && len < max_len2)
        max_len3 = len;
        xy_long3 = xy;
    end
end
% 显示上述线段
plot(xy_long(:,1), xy_long(:,2), 'LineWidth', 2, 'Color', 'red'); % 绘制线段红色为最终结果
plot(xy_long1(:,1), xy_long1(:,2), 'LineWidth', 2, 'Color', 'red');
plot(xy_long2(:,1), xy_long2(:,2), 'LineWidth', 2, 'Color', 'red');
plot(xy_long3(:,1), xy_long3(:,2), 'LineWidth', 2, 'Color', 'red');
title('检测结果');
% 将检测结果显示在原图上
figure(10);
imshow(img1);
hold on;
plot(xy_long(:,1), xy_long(:,2), 'LineWidth', 2, 'Color', 'red');
plot(xy_long1(:,1), xy_long1(:,2), 'LineWidth', 2, 'Color', 'red');
plot(xy_long2(:,1), xy_long2(:,2), 'LineWidth', 2, 'Color', 'red');
plot(xy_long3(:,1), xy_long3(:,2), 'LineWidth', 2, 'Color', 'red');
title('检测结果');
% 添加图例
legend('检测结果');