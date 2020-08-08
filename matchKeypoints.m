function matchedKeyPoints = matchKeypoints(siftDetails, dictionary)

matchIndex = 1;
for i=1:length(siftDetails)
   siftOctaveDetails = siftDetails{i};
   
   for j=1:length(siftOctaveDetails)
      match = keypointMatch(dictionary.dictionary, siftOctaveDetails(j).descriptor);
      if match.found==1
         matchedKeyPoints(matchIndex).minIndex = match.minIndex;
         matchedKeyPoints(matchIndex).secondMinIndex = match.secondMinIndex;
         matchedKeyPoints(matchIndex).siftDetail = siftOctaveDetails(j);
         matchIndex = matchIndex + 1;
      end
   end
end

end

