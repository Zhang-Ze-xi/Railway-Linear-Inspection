%% 问题描述：
% 首先我们对这个问题进行分析，本问题根本目的在于通过图形变换，将视角中
% 的铁道两条斜线变为平行的两条直线，也就是将整体图形变为鸟瞰图，这样方便
% 后续的识别
% 首先我们对该图像进行灰度化处理，然后进行二值化处理
% 二值化处理后，我们对图像进行膨胀处理，这样可以使得铁道的两条斜线变为
% 一条直线，这样方便后续的识别
% 接下来我们对图像进行霍夫变换，得到图像中的直线
% 然后我们对直线进行筛选，筛选出两条直线，这两条直线就是铁道的两条斜线
% 然后我们对这两条直线进行变换，将其变为平行的两条直线
% 最后我们对图像进行透视变换，得到鸟瞰图
% 问题分析：
% 1.对图像进行灰度化处理
clear;
clc;
close all;
img = imread('F:\VS Code\Matlab\Project\Project1\text.jpg');
img = rgb2gray(img);
figure(1);
imshow(img);
title('灰度化处理后的图像');
% 2.对图像进行灰度拉伸处理
img1 =imadjust(img,[0.3,0.9],[]); 
figure(2);
imshow(img1);
title('灰度拉伸处理后的图像');
% 3.对图像进行二值化处理
img2 = im2bw(img1,0.5); 
figure(3);
imshow(img2);
title('二值化处理后的图像');
% 4.对图像进行膨胀处理
img3 = imdilate(img2,strel('disk',1)); % 对图像进行膨胀处理
figure(4);
imshow(img3);
title('膨胀处理后的图像');
% 5.对图像进行霍夫变换
[H,T,R] = hough(img3);
figure(5);
imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
lines = houghlines(img3,T,R,P,'FillGap',5,'MinLength',7);
figure(6);
imshow(img3), hold on
max_len = 0;
for k = 1:length(lines)
xy = [lines(k).point1; lines(k).point2];
plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 绘制线条的起点和终点
plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 确定最长线段的端点
len = norm(lines(k).point1 - lines(k).point2);
if ( len > max_len)
max_len = len;
xy_long = xy;
end
end
% 确定第二长线段的端点
max_len1 = 0;
for k = 1:length(lines)
xy = [lines(k).point1; lines(k).point2];
len = norm(lines(k).point1 - lines(k).point2);
if ( len > max_len1 && len < max_len)
max_len1 = len;
xy_long1 = xy;
end
end
% 绘制最长线段
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
% 绘制第二长的线段
plot(xy_long1(:,1),xy_long1(:,2),'LineWidth',2,'Color','red');
% 绘制产生的线段中的最长线段为红色，是我们的识别结果，其余绿色部分是我们
% 识别出来的线段（疑似结果）
% 6.对直线进行筛选
% 7.对直线进行变换
% 8.对图像进行透视变换
% 9.显示图像
% 10.保存图像
% 11.结束程序