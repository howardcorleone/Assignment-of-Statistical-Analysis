function [information,image_compression] = compression(filename, r)
    image = imread(filename);
    %[row, col] = size(image);  %��ȡͼƬ���ص�����������

    %��ͼ���Ϊ16*16��С�飬����512*512��ͼƬ��һ��32*32=1024��
    X = zeros(16,16,1024);  %�������X1,X2,...,X1024
    region_size=16;
    numRow=32;
    numCol=32;
    t1 = (0:numRow-1)*region_size + 1; t2 = (1:numRow)*region_size;
    t3 = (0:numCol-1)*region_size + 1; t4 = (1:numCol)*region_size;
    %figure; 
    k = 0; 
    for i = 1 : numRow
        for j = 1 : numCol
            temp = image(t1(i):t2(i), t3(j):t4(j), :);
            k = k + 1;
            X(:,:,k) = temp;
    %         subplot(numRow, numCol, k);
    %         imshow(temp);
        end
    end

    %��ÿһ���ֵ�ͼ�������ɷַ���
    Y = zeros(16,16,1024);
    total = 0;
    part = 0;
    for i = 1:1024
        [u,s,v] = svd(double(X(:,:,i)));

        %�ع�ѹ�����ͼ��
        %r = 4;    %ѹ����
        %K = round(16 / r);
        K =round(2 * region_size * region_size / ( r * (region_size + region_size + 1)));

        if K > region_size
            K = region_size;
        end

        Y(:,:,i) = zeros(size(X(:,:,i)));
        for j = 1:K
            Y(:,:,i) = Y(:,:,i) + s(j,j) * u(:,j) * v(:,j)';    % ����ǰK������ֵ�ع�ԭͼ��
        end

        %������Ϣ��
        total = total + sum(diag(s));
        for w = 1:K
            part = part + s(w,w);
        end
    end

    %��С��ϳ�һ��ͼ
    image_compression = zeros(1,512);
    for j = 1:32
        image_compression_row = Y(:,:,(j-1)*32+1);
        for k = 2:32
                image_compression_row = cat(2, image_compression_row, Y(:,:,(j-1)*32+k));
        end
        image_compression = cat(1, image_compression, image_compression_row);
    end
    image_compression(1,:) = [];

    %������Ϣ��
    % total = sum(diag(s));
    % part = 0;
    % for i = 1:K
    %     part = part + s(i,i);
    % end
    information = part / total;

end