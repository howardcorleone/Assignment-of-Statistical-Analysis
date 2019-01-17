clear;
% im1 = imread('./att_faces/s39/1.pgm');
% imshow(im1);
% im1 = reshape(im1, [1,112*92]);

% ������ͼƬ�洢�ھ���data�У���400�У�����400��ͼƬ��ÿ�м�ÿ��ͼƬ��ʾ��һ��112*92ά������
data = zeros(400,112*92);
att_faces = dir('./att_faces');
count = 1;
for i=4:43
    file = dir(['./att_faces/', att_faces(i).name]);
    for j=3:12
        temp = imread(['./att_faces/', att_faces(i).name, '/', file(j).name]);
        data(count,:) = reshape(temp, [1,112*92]);
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
% [coeff,score,latent,tsquared,explained,mu] = pca(data, 'Centered', false);
[coeff,score,latent,tsquared,explained,mu] = pca(data);

% ͶӰ����
projection_matrix = coeff(:,1:40);
% ����ͶӰ�������pcaѹ����Ľ��
data_pca = data * projection_matrix;

%k-means(���ý�ά����������о���)
disp('Clustering by Reduced Dimension Features:');
% ÿ��ͼ�ı�ǩ
labels = zeros(1,400);
for i = 1:400
    labels(i) = ceil(i/10);
end
% ѡȡ��ʼ��
cluster = zeros(40,40);  % ÿһ�д���һ����
for i = 1:40
    cluster(i,:) = data_pca(10*(i-1)+1,:);
end
number_of_iterations = 0;
% ��ʼ����
while 1
    % ����ÿ��ͼӦ�ù����ĸ���
    distance = zeros(40,400);  % distance��ÿһ�д���ĳ��ͼ��40����֮���ŷʽ����
    for i = 1:40
        distance(i,:) = dist(cluster(i,:), data_pca');
    end
    cluster_belong_to = zeros(1,400);
    for i = 1:400
        [~,kmeans_index] = min(distance(:,i));
        cluster_belong_to(i) = kmeans_index;
    end
    % ����µ����ֵ
    new_cluster = zeros(40,40);
    for i = 1:40
        temp = find(cluster_belong_to == i);
        for j = 1:size(temp, 2)
            new_cluster(i,:) = new_cluster(i,:) + data_pca(temp(j),:);
        end
        new_cluster(i,:) = new_cluster(i,:) / size(temp, 2);
    end
    % ��ÿ������ϱ�ǩ
    labels_of_cluster = zeros(1,40);
    for i = 1:40
        G = zeros(1,40);  % ��¼ÿһ�����и�����ǩ���ֵĴ���
        temp = find(cluster_belong_to == i);
        for j = 1:size(temp, 2)
            G(labels(temp(j))) = G(labels(temp(j))) + 1;
        end
        [~,t] = max(G);
        labels_of_cluster(i) = t;
    end
    % �������������ֵ��֮ǰ�Ĳ����
    if ~isequal(cluster, new_cluster)
        cluster = new_cluster;
        number_of_iterations = number_of_iterations + 1;
        disp(['Now the number of iterations is ', num2str(number_of_iterations)]);
    % �������������ֵ��֮ǰ�����
    else 
        % ����׼ȷ��
        kmeans_collect_num_pca = 0;
        for i = 1:400
            n = cluster_belong_to(i);
            if labels_of_cluster(n) == labels(i)
                kmeans_collect_num_pca = kmeans_collect_num_pca + 1;
            end
        end
        kmeans_accuracy_pca = kmeans_collect_num_pca / 400;
        disp(['Iterative completed. The accuracy obtained by kmeans is ', num2str(kmeans_accuracy_pca*100), '%']);
        break;
    end
end

%k-means(����ͼƬ�����������о���)
disp('Clustering Using All Characters of Pictures:');
% ÿ��ͼ�ı�ǩ
labels = zeros(1,400);
for i = 1:400
    labels(i) = ceil(i/10);
end
% ѡȡ��ʼ��
cluster = zeros(40,112*92);  % ÿһ�д���һ����
for i = 1:40
    cluster(i,:) = data(10*(i-1)+1,:);
end
number_of_iterations = 0;
% ��ʼ����
while 1
    % ����ÿ��ͼӦ�ù����ĸ���
    distance = zeros(40,400);  % distance��ÿһ�д���ĳ��ͼ��40����֮���ŷʽ����
    for i = 1:40
        distance(i,:) = dist(cluster(i,:), data');
    end
    cluster_belong_to = zeros(1,400);
    for i = 1:400
        [~,kmeans_index] = min(distance(:,i));
        cluster_belong_to(i) = kmeans_index;
    end
    % ����µ����ֵ
    new_cluster = zeros(40,112*92);
    for i = 1:40
        temp = find(cluster_belong_to == i);
        for j = 1:size(temp, 2)
            new_cluster(i,:) = new_cluster(i,:) + data(temp(j),:);
        end
        new_cluster(i,:) = new_cluster(i,:) / size(temp, 2);
    end
    % ��ÿ������ϱ�ǩ
    labels_of_cluster = zeros(1,40);
    for i = 1:40
        G = zeros(1,40);  % ��¼ÿһ�����и�����ǩ���ֵĴ���
        temp = find(cluster_belong_to == i);
        for j = 1:size(temp, 2)
            G(labels(temp(j))) = G(labels(temp(j))) + 1;
        end
        [~,t] = max(G);
        labels_of_cluster(i) = t;
    end
    % �������������ֵ��֮ǰ�Ĳ����
    if ~isequal(cluster, new_cluster)
        cluster = new_cluster;
        number_of_iterations = number_of_iterations + 1;
        disp(['Now the number of iterations is ', num2str(number_of_iterations)]);
    % �������������ֵ��֮ǰ�����
    else 
        % ����׼ȷ��
        kmeans_collect_num = 0;
        for i = 1:400
            n = cluster_belong_to(i);
            if labels_of_cluster(n) == labels(i)
                kmeans_collect_num = kmeans_collect_num + 1;
            end
        end
        kmeans_accuracy = kmeans_collect_num / 400;
        disp(['Iterative completed. The accuracy obtained by kmeans is ', num2str(kmeans_accuracy*100), '%']);
        break;
    end
end
