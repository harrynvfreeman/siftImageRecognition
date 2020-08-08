SIFT Descriptor / Object recognition based off of https://www.cs.ubc.ca/~lowe/papers/ijcv04.pdf.
Used images from Home Objects data set for training http://www.vision.caltech.edu/pmoreels/Datasets/Home_Objects_06/

To run:

1) Build the dictionary.  Put training images in a file path and call buildDictionary (make sure all image extensions are specified in buildDictionary). Specify numOctaves per (suggested numOctaves based on paper is 4).  Specify resizeFactor (size training images are resized before dictionary is build, affects speed and accuracy).  When buildDictionary is called select the bath you put the training images in.

2) Call matchImageToDictionary.  Specify the image path to be matched, as well as the resize factor for the image and the number of octaves used in descriptor calculations.  Output is a cell array of all matched images.

For example see main.m

Files:
buildDictionary.m - builds the dictionary of training images

calcEuclidian.m - calculates the euclidian distance between two key point descriptors

diffOfGaussians.m - calculates the difference of gaussians used to approximate the scale-normalized Laplacian of Gaussian

elimEdgeResponse.m - rejects edge key points

findDescriptors.m - calculates the key point descriptors

findExtremas.m - finds the first pass of extremes using neighboring difference of gaussians

findOrientation.m - calculates histogram used for key point orientation

findSigmaIndex.m - used to find the new matlab sigma index in localization

fitPeaks.m - used to fit the histogram peaks to key points

houghVote.m - uses hough transform to vote key point yTranslation, xTranslation, scaleChange, and rotation into bins.  If keypoints in a bin do not have at least 3 votes they are rejected.

keypointMatch.m - used to match a single keypoint to dictionary key points

localize.m - localizes extremes by using Taylor Series

main.m - example of how to buildDictionary and run code

matchImageToDictionary.m - matches an image to dictionary and shows how detected key points align in output images

matchKeypoints.m - matches keypoints found in sift key point calculations to dictionary

matchSiftToDictionary.m - deprecated. matches key points to dictionary without hough voting and combines images

matchSiftToDictionary2.m - matches key points to dictionary with hough voting and combines images

multGaussianFilter.m - calculates gaussians used for difference of gaussians and key point histograming

multOctave.m - processes sift calculations across multiple octaves

prepareImage.m - Image preprocessing by reading from file, converting to grayscale and double, and resizing if specified

processOctave.m - processes sift calculations for single octave

toDo.m - just comments of what is left to implement and refine

siftExample(n).jpeg - saved output images from main.m