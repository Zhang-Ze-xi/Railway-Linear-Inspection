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
% 键入图片名称导入图像
% Version 1.0 完成基础的图像处理与轨道线提取
% Version 2.0 完成对视频的处理与轨道线提取
% Version 3.0 完成对处理对象的判断，可以处理图片或视频
% 通过输入字符判断处理对象为图片还是视频
judge = input('请输入处理对象：1.图片 2.视频');
if judge == 2
    se = strel('line', 11, 90); %定义结构元素
    % 读取视频
    path = input('请输入视频名称：(注意后面要加上文件格式例如：1.mp4)', 's'); %视频存放路径
    obj = VideoReader(path);
    num = obj.NumberOfFrames;

    for i = 1:num %帧数
        frame = read(obj, i);
        lujing = strcat('F:\VS Code\Matlab\Project\Project1\framechart\', num2str(i)); %帧图输出路径
        lujing = strcat(lujing, '.jpg'); %帧图输出路径
        imwrite(frame, lujing)
    end

    for i = 1:num % 前面所得的视频帧数
        path = 'F:\VS Code\Matlab\Project\Project1\framechart\'; % 帧图路径
        disp(i); % 显示当前帧数
        path = strcat(path, num2str(i)); %  1.确定帧图路径
        p = strcat(path, '.jpg'); %  2.确定帧图格式
        img = imread(p); %  3.读取帧图
        figure(1);
        imshow(img);
        title('原图像');
        % 测量图像大小
        [height, width, channel] = size(img); % height为图像高度，width为图像宽度，channel为图像通道数
        % 在工作区显示图像大小
        disp(['图像大小为：（width x height x channel）', num2str(width), ' x ', num2str(height), ' x ', num2str(channel)]);
        % 选定感兴趣区域，先使用阅读器查看图片，剪裁操作试一下大概的感兴趣区域
        % 输入感兴趣区域的左上角坐标和右下角坐标
        % 例如：左上角坐标为（1，1），右下角坐标为（359，132）
        % 则输入：1 1 359 132
        % 之后，程序会自动将感兴趣区域提取出来
        %     % 输入四个值
        %     x1 = input('请输入感兴趣区域左上角横坐标：');
        %     y1 = input('请输入感兴趣区域左上角纵坐标：');
        %     x2 = input('请输入感兴趣区域右下角横坐标：');
        %     y2 = input('请输入感兴趣区域右下角纵坐标：');
        %     % 本执行例中，我们选定的感兴趣区域为（1，1）到（359,132）
        %     % 即x1=1, y1=1, x2=359, y2=132
        %     img1 = img(y1:y2, x1:x2, :); % img1为感兴趣区域，img(1:height, 1:width, :);
        %     figure(2);
        %     imshow(img1);
        %     title('感兴趣区域');
        img1 = img;
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
        % Prewitt边缘检测
        img6 = edge(img5, 'Prewitt');
        figure(7);
        imshow(img6);
        title('Prewitt边缘检测');
        % % Sobel边缘检测
        % img6 = edge(img5, 'Sobel');
        % figure(7);
        % imshow(img6);
        % title('Sobel边缘检测');
        % % Canny边缘检测
        % img6 = edge(img5, 'Canny');
        % figure(7);
        % imshow(img6);
        % title('Canny边缘检测');
        % Hough变换直线检测
        [H, theta, rho] = hough(img6); % H为霍夫变换图像，theta为角度，rho为距离
        figure(8);
        imshow(imadjust(mat2gray(H)), 'XData', theta, 'YData', rho, 'InitialMagnification', 'fit'); % 绘制霍夫变换图像
        xlabel('\theta (degrees)');
        ylabel('\rho');
        axis on; % 显示坐标轴
        axis normal; % 保持图像比例
        hold on; % 保持图像
        colormap(gca, hot);
        P = houghpeaks(H, 5, 'threshold', ceil(0.3 * max(H(:)))); % 选取霍夫变换图像中的峰值点
        x = theta(P(:, 2));
        y = rho(P(:, 1));
        plot(x, y, 's', 'color', 'black');
        lines = houghlines(img6, theta, rho, P, 'FillGap', 5, 'MinLength', 7); % 用霍夫变换图像中的峰值点检测直线
        figure(9);
        imshow(img6); % 绘制检测结果
        hold on;
        % 绘制直线并确定最长的线段
        max_len = 0;

        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            plot(xy(:, 1), xy(:, 2), 'LineWidth', 2, 'Color', 'yellow'); % 绘制线段黄色为疑似结果
            % 绘制线条的起点和终点
            plot(xy(1, 1), xy(1, 2), 'x', 'LineWidth', 2, 'Color', 'green');
            plot(xy(2, 1), xy(2, 2), 'x', 'LineWidth', 2, 'Color', 'green');
            % 确定最长线段的端点
            len = norm(lines(k).point1 - lines(k).point2);

            if (len > max_len)
                max_len = len;
                xy_long = xy;
            end

        end

        % 确定第二长的线段
        max_len1 = 0;

        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            len = norm(lines(k).point1 - lines(k).point2);

            if (len > max_len1 && len < max_len)
                max_len1 = len;
                xy_long1 = xy;
            end

        end

        % 确定第三长的线段
        max_len2 = 0;

        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            len = norm(lines(k).point1 - lines(k).point2);

            if (len > max_len2 && len < max_len1)
                max_len2 = len;
                xy_long2 = xy;
            end

        end

        % 确定第四长的线段
        max_len3 = 0;

        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            len = norm(lines(k).point1 - lines(k).point2);

            if (len > max_len3 && len < max_len2)
                max_len3 = len;
                xy_long3 = xy;
            end

        end

        % 确定第五长的线段
        max_len4 = 0;

        for k = 1:length(lines)
            xy = [lines(k).point1; lines(k).point2];
            len = norm(lines(k).point1 - lines(k).point2);

            if (len > max_len4 && len < max_len3)
                max_len4 = len;
                xy_long4 = xy;
            end

        end

        % 显示上述线段
        plot(xy_long(:, 1), xy_long(:, 2), 'LineWidth', 2, 'Color', 'red'); % 绘制线段红色为最终结果
        plot(xy_long1(:, 1), xy_long1(:, 2), 'LineWidth', 2, 'Color', 'red');
        plot(xy_long2(:, 1), xy_long2(:, 2), 'LineWidth', 2, 'Color', 'red');
        plot(xy_long3(:, 1), xy_long3(:, 2), 'LineWidth', 2, 'Color', 'red');
        plot(xy_long4(:, 1), xy_long4(:, 2), 'LineWidth', 2, 'Color', 'red');
        title('检测结果');
        % 计算上述线段的斜率
        k1 = (xy_long(1, 2) - xy_long(2, 2)) / (xy_long(1, 1) - xy_long(2, 1));
        k2 = (xy_long1(1, 2) - xy_long1(2, 2)) / (xy_long1(1, 1) - xy_long1(2, 1));
        k3 = (xy_long2(1, 2) - xy_long2(2, 2)) / (xy_long2(1, 1) - xy_long2(2, 1));
        k4 = (xy_long3(1, 2) - xy_long3(2, 2)) / (xy_long3(1, 1) - xy_long3(2, 1));
        k5 = (xy_long4(1, 2) - xy_long4(2, 2)) / (xy_long4(1, 1) - xy_long4(2, 1));
        % 得到上述线段所在的直线方程
        a1 = xy_long(1, 2) - k1 * xy_long(1, 1);
        a2 = xy_long1(1, 2) - k2 * xy_long1(1, 1);
        a3 = xy_long2(1, 2) - k3 * xy_long2(1, 1);
        a4 = xy_long3(1, 2) - k4 * xy_long3(1, 1);
        a5 = xy_long4(1, 2) - k5 * xy_long4(1, 1);
        % 在原图上显示直线
        figure(10);
        imshow(img1);
        hold on;
        x = 1:1:640;
        y1 = k1 * x + a1;
        y2 = k2 * x + a2;
        y3 = k3 * x + a3;
        y4 = k4 * x + a4;
        y5 = k5 * x + a5;
        plot(x, y1, 'LineWidth', 2, 'Color', 'red');
        plot(x, y2, 'LineWidth', 2, 'Color', 'red');
        %     plot(x, y3, 'LineWidth', 2, 'Color', 'red');
        %     plot(x, y4, 'LineWidth', 2, 'Color', 'red');
        %     plot(x, y5, 'LineWidth', 2, 'Color', 'red');
        title('检测结果');
        legend('检测结果'); % 添加图例
        % 将上图导出为图片
        mh = figure(10); %  1.获取图片句柄
        lujing = strcat('F:\VS Code\Matlab\Project\Project1\testresults\', num2str(i)); %  3.输出存放路径
        lujing = strcat(lujing, '.jpg'); %  4.输出格式为ipg
        saveas(mh, lujing); %  5.保存图片,saveas(图片句柄,图片路径)
        % 这里默认是将边缘检测的每一张图片保存，方便后续合成视频；
        pause(0.05);
    end

    WriterObj = VideoWriter('Test results.mp4', 'MPEG-4'); %这里输出的路径是默认路径，合成的视频的格式是MP4
    %avi格式的话过于高清，可以改为mp4，这样就合成的视频比较小
    %改为avi格式只需将内容改为：('Test results.avi', 'Uncompressed AVI');
    open(WriterObj);

    for i = 1:num %帧图数量
        pic = 'F:\VS Code\Matlab\Project\Project1\testresults\'; %前面边缘检测的图片的存储路径
        pic = strcat(pic, num2str(i));
        ppic = strcat(pic, '.jpg');
        frame = imread(ppic); % 读取图像，放在变量frame中
        disp(ppic);
        writeVideo(WriterObj, frame); % 将frame放到变量WriterObj中
    end

    close(WriterObj);
elseif judge == 1
    img = imread(input('请输入图片名称：(注意后面要加上文件格式例如：1.jpg)', 's'));
    figure(1);
    imshow(img);
    title('原图像');
    % 测量图像大小
    [height, width, channel] = size(img); % height为图像高度，width为图像宽度，channel为图像通道数
    % 在工作区显示图像大小
    disp(['图像大小为：（width x height x channel）', num2str(width), ' x ', num2str(height), ' x ', num2str(channel)]);
    % 选定感兴趣区域，先使用阅读器查看图片，剪裁操作试一下大概的感兴趣区域
    % 输入感兴趣区域的左上角坐标和右下角坐标
    % 例如：左上角坐标为（1，1），右下角坐标为（359，132）
    % 则输入：1 1 359 132
    % 之后，程序会自动将感兴趣区域提取出来
    % 输入四个值
    x1 = input('请输入感兴趣区域左上角横坐标：');
    y1 = input('请输入感兴趣区域左上角纵坐标：');
    x2 = input('请输入感兴趣区域右下角横坐标：');
    y2 = input('请输入感兴趣区域右下角纵坐标：');
    % 本执行例中，我们选定的感兴趣区域为（1，1）到（359,132）
    % 即x1=1, y1=1, x2=359, y2=132
    img1 = img(y1:y2, x1:x2, :); % img1为感兴趣区域，img(1:height, 1:width, :);
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
    % Prewitt边缘检测
    img6 = edge(img5, 'Prewitt');
    figure(7);
    imshow(img6);
    title('Prewitt边缘检测');
    % % Sobel边缘检测
    % img6 = edge(img5, 'Sobel');
    % figure(7);
    % imshow(img6);
    % title('Sobel边缘检测');
    % % Canny边缘检测
    % img6 = edge(img5, 'Canny');
    % figure(7);
    % imshow(img6);
    % title('Canny边缘检测');
    % Hough变换直线检测
    [H, theta, rho] = hough(img6); % H为霍夫变换图像，theta为角度，rho为距离
    figure(8);
    imshow(imadjust(mat2gray(H)), 'XData', theta, 'YData', rho, 'InitialMagnification', 'fit'); % 绘制霍夫变换图像
    xlabel('\theta (degrees)');
    ylabel('\rho');
    axis on; % 显示坐标轴
    axis normal; % 保持图像比例
    hold on; % 保持图像
    colormap(gca, hot);
    P = houghpeaks(H, 5, 'threshold', ceil(0.3 * max(H(:)))); % 选取霍夫变换图像中的峰值点
    x = theta(P(:, 2));
    y = rho(P(:, 1));
    plot(x, y, 's', 'color', 'black');
    lines = houghlines(img6, theta, rho, P, 'FillGap', 5, 'MinLength', 7); % 用霍夫变换图像中的峰值点检测直线
    figure(9);
    imshow(img6); % 绘制检测结果
    hold on;
    % 绘制直线并确定最长的线段
    max_len = 0;

    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:, 1), xy(:, 2), 'LineWidth', 2, 'Color', 'yellow'); % 绘制线段黄色为疑似结果
        % 绘制线条的起点和终点
        plot(xy(1, 1), xy(1, 2), 'x', 'LineWidth', 2, 'Color', 'green');
        plot(xy(2, 1), xy(2, 2), 'x', 'LineWidth', 2, 'Color', 'green');
        % 确定最长线段的端点
        len = norm(lines(k).point1 - lines(k).point2);

        if (len > max_len)
            max_len = len;
            xy_long = xy;
        end

    end

    % 确定第二长的线段
    max_len1 = 0;

    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        len = norm(lines(k).point1 - lines(k).point2);

        if (len > max_len1 && len < max_len)
            max_len1 = len;
            xy_long1 = xy;
        end

    end

    % 确定第三长的线段
    max_len2 = 0;

    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        len = norm(lines(k).point1 - lines(k).point2);

        if (len > max_len2 && len < max_len1)
            max_len2 = len;
            xy_long2 = xy;
        end

    end

    % 确定第四长的线段
    max_len3 = 0;

    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        len = norm(lines(k).point1 - lines(k).point2);

        if (len > max_len3 && len < max_len2)
            max_len3 = len;
            xy_long3 = xy;
        end

    end

    % 确定第五长的线段
    max_len4 = 0;

    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        len = norm(lines(k).point1 - lines(k).point2);

        if (len > max_len4 && len < max_len3)
            max_len4 = len;
            xy_long4 = xy;
        end

    end

    % 显示上述线段
    plot(xy_long(:, 1), xy_long(:, 2), 'LineWidth', 2, 'Color', 'red'); % 绘制线段红色为最终结果
    plot(xy_long1(:, 1), xy_long1(:, 2), 'LineWidth', 2, 'Color', 'red');
    plot(xy_long2(:, 1), xy_long2(:, 2), 'LineWidth', 2, 'Color', 'red');
    plot(xy_long3(:, 1), xy_long3(:, 2), 'LineWidth', 2, 'Color', 'red');
    plot(xy_long4(:, 1), xy_long4(:, 2), 'LineWidth', 2, 'Color', 'red');
    title('检测结果');
    % 计算上述线段的斜率
    k1 = (xy_long(1, 2) - xy_long(2, 2)) / (xy_long(1, 1) - xy_long(2, 1));
    k2 = (xy_long1(1, 2) - xy_long1(2, 2)) / (xy_long1(1, 1) - xy_long1(2, 1));
    k3 = (xy_long2(1, 2) - xy_long2(2, 2)) / (xy_long2(1, 1) - xy_long2(2, 1));
    k4 = (xy_long3(1, 2) - xy_long3(2, 2)) / (xy_long3(1, 1) - xy_long3(2, 1));
    k5 = (xy_long4(1, 2) - xy_long4(2, 2)) / (xy_long4(1, 1) - xy_long4(2, 1));
    % 得到上述线段所在的直线方程
    a1 = xy_long(1, 2) - k1 * xy_long(1, 1);
    a2 = xy_long1(1, 2) - k2 * xy_long1(1, 1);
    a3 = xy_long2(1, 2) - k3 * xy_long2(1, 1);
    a4 = xy_long3(1, 2) - k4 * xy_long3(1, 1);
    a5 = xy_long4(1, 2) - k5 * xy_long4(1, 1);
    % 在原图上显示直线
    figure(10);
    imshow(img1);
    hold on;
    x = 1:1:640;
    y1 = k1 * x + a1;
    y2 = k2 * x + a2;
    y3 = k3 * x + a3;
    y4 = k4 * x + a4;
    y5 = k5 * x + a5;
    plot(x, y1, 'LineWidth', 2, 'Color', 'red');
    plot(x, y2, 'LineWidth', 2, 'Color', 'red');
    plot(x, y3, 'LineWidth', 2, 'Color', 'red');
    plot(x, y4, 'LineWidth', 2, 'Color', 'red');
    plot(x, y5, 'LineWidth', 2, 'Color', 'red');
    title('检测结果');
    legend('检测结果'); % 添加图例
    % 将上图导出为图片
    print(10, '-djpeg', '结果.jpg');
end
