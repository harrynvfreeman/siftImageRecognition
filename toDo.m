%Code Solution for Affine Parameters.  May fix some of the incorrect
% matches I am seeing.

%when calculate derivate values for scale space, should I use differnece of
%sigma values or 1?  Using difference of sigma values but other resources
%that have implemented this use 1, but paper sounds like should use
%difference of sigmas.  See localize.m

%SPEED UP, not super efficient right now.

%Currently a little too sensitive to scale. Scale change reduces number matched keypoints significantly,
%Need to improve this - am I
%not doing octave calculations correctly?

%Look into why when dictionary train resize is very different than test
%resize the image is not matched. IE dictionary resize is 1/3 using
%book.png and
%[output, octaveCount] = matchImageToDictionary('bookHiding.png', 1/3, 4, dictionary);
%find output fine but using 1/4 or 1/2 does not.  Just this example, others
%work

%Confirm if sigma = 1.6 should be used as the starting sigma for each
%octave or if should call sigma=nextScale in multOctave.m

%Do one more read through of code to make sure everything looks okay

%Look through code and see if any concerns