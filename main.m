%demo example.  images used are in gitTrainingSet  
%All images except for 2 are from the Home Objects dataset
%http://www.vision.caltech.edu/pmoreels/Datasets/Home_Objects_06/
%One image is the staple remover from  
%https://www.mathworks.com/help/vision/examples/object-detection-in-a-cluttered-scene-using-point-feature-matching.html
%One image is the bastoncini box from 
%https://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_feature2d/py_matcher/py_matcher.html
dictionary = buildDictionary(4, 1/3);

%let's start with an example by resizing, rotating, and blurring an image
%select trainImage directory
myDir = uigetdir;
imagePath = fullfile(myDir, '3.jpeg');
imageToModify = im2double(imread(imagePath));
imageToModify = imresize(imageToModify, 1.22);
noise = (rand(size(imageToModify)) - 0.5)/50; %uniform random noise between [-0.01, 0.01] as in paper
imageToModify = imageToModify + noise;
imageToModify(imageToModify > 1) = 1;
imageToModify(imageToModify < 0) = 0;
imageToModify = imrotate(imageToModify, 42);
imwrite(imageToModify, 'testImage.jpeg');
[output, ~] = matchImageToDictionary('testImage.jpeg', 1/3, 4, dictionary);
%I have one matched image.  Let's display it
figure
imshow(output{1})
%save for git
imwrite(output{1}, 'siftExample1.jpeg')

%A more complicated example using bastoncini box
imagePath = 'boxHiding.png';
[output, ~] = matchImageToDictionary(imagePath, 1/3, 4, dictionary);
%Again I have one matched image.  Let's display it
figure
imshow(output{1})
imwrite(output{1}, 'siftExample2.jpeg')

%Final example.  Need larger resize as object is too small in test image
imagePath = 'matlabTest.png';
[output, ~] = matchImageToDictionary(imagePath, 1/2, 4, dictionary);
%This time I have 3 matched images.  Let's display them
for i=1:length(output)
    figure
    imshow(output{i})
end
%A majority of the matches are from the correct object.  However, there 
%are 3 incorrect pixel matches, one in each image.  Possible reasons include have not
%implemented affine parameters yet, as well as not enough training images.
%As well, for the incorrect matches, they are each only one pixel, but are
%being matched because there are multiple keypoints per pixel (80%
%threshold from paper).  Could reduce the 2 incorrect image matches by
%requiring more than 1 pixel to be matched.
imwrite(output{3}, 'siftExample3.jpeg')
imwrite(output{1}, 'siftExample3MisMatch1.jpeg')
imwrite(output{2}, 'siftExample3MisMatch2.jpeg')