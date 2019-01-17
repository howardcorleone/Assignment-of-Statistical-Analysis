clear;
% im1 = imread('./att_faces/s39/1.pgm');
% imshow(im1);
% im1 = reshape(im1, [1,112*92]);

% ��ѵ�����ݴ洢�ھ���train_data�У���240�У�����240��ͼƬ��ÿ�м�ÿ��ͼƬ��ʾ��һ��112*92ά������
train_data = zeros(240,112*92);
att_faces = dir('./att_faces');
count = 1;
for i=4:43
    file = dir(['./att_faces/', att_faces(i).name]);
    for j=[3,5,6,7,8,9]
        temp = imread(['./att_faces/', att_faces(i).name, '/', file(j).name]);
        train_data(count,:) = reshape(temp, [1,112*92]);
        count = count + 1;
    end
end

% ���������ݴ洢�ھ���test_data�У���160�У�����160��ͼƬ��ÿ�м�ÿ��ͼƬ��ʾ��һ��112*92ά������
test_data = zeros(160,112*92);
att_faces = dir('./att_faces');
count = 1;
for i=4:43
    file = dir(['./att_faces/', att_faces(i).name]);
    for j=[10,11,12,4]
        temp = imread(['./att_faces/', att_faces(i).name, '/', file(j).name]);
        test_data(count,:) = reshape(temp, [1,112*92]);
        count = count + 1;
    end
end

% ���ɷַ���
% coeffΪԭ�����Э����������������������ֵ��ѡ����k(=40)������ѡ���Ӧ��k������������
% ͶӰ����Ϊcoeffǰk�С�
% scoreΪ����pcaѹ��������ݡ�
% latentΪ�Ӵ�С���������ֵ��
% explainedΪÿ�����ɷֶ�Ӧ�Ĺ��ױ�����
% muΪԭ����ÿ�еľ�ֵ��ȡ�����Ļ�����֮��muΪ0��
% [coeff,score,latent,tsquared,explained,mu] = pca(train_data, 'Centered', false);
[coeff,score,latent,tsquared,explained,mu] = pca(train_data);

% ͶӰ����
projection_matrix = coeff(:,1:40);
% ����ͶӰ�������pcaѹ����Ľ��
train_data_pca = train_data * projection_matrix;

% ����ѵ���������ͶӰ����;�ֵ���Բ��Լ���ÿһ��ͼ��10304ά�ȣ���ά��40ά�ȡ��õ�160*40����160��ͼ��ĸ�����40��ά�ȡ�
test_data_pca = test_data * projection_matrix;


% ����ʶ����ƥ��
% ŷʽ����
euclidean_distance = dist(train_data_pca, test_data_pca');
[~,euclidean_index] = min(euclidean_distance);
euclidean_collect_num = 0;
for i=1:160
    if strcmp(att_faces(ceil(euclidean_index(i)/6)+3).name, att_faces(ceil(i/4)+3).name)
        euclidean_collect_num = euclidean_collect_num + 1;
    end
end
euclidean_accuracy = euclidean_collect_num / 160;
disp(['The accuracy obtained by Euclidean distance matching method is ', num2str(euclidean_accuracy*100), '%']);
