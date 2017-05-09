PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

  // First pass: label the pixels and store labels’ equivalences
  int [] labels = new int [input.width*input.height];
  List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
  labelsEquivalences.add(null); //Note: only here to simplify accesses (i add a useless element at index 0, s.t. all access work later on)

  int currentLabel = 1;

  for (int row = 1; row < input.height - 1; row++) { // Skip left & right col
    for (int col = 1; col < input.width - 1; col++) { // Skip top & bottom row

      //if pixel is background, don't do anything
      if (input.pixels[row * input.width + col] != color(0)) {
        TreeSet<Integer> neighbors = new TreeSet<Integer>() ;


        //Retain all neighbors that have a label already and save the label
        int neighborW = labels[(row) * input.width + (col-1)];
        if (neighborW > 0) neighbors.add(neighborW);
        int neighborNW = labels[(row-1) * input.width + (col-1)];
        if (neighborNW > 0) neighbors.add(neighborNW);
        int neighborN = labels[(row-1) * input.width + (col)];
        if (neighborN > 0) neighbors.add(neighborN);
        int neighborNE = labels[(row-1) * input.width + (col+1)];
        if (neighborNE > 0) neighbors.add(neighborNE);

        //Depending on neighbor value, give label to current pixel
        if (neighbors.isEmpty()) {
          labels[row * input.width + col] = currentLabel;
          TreeSet<Integer> newEquivalenceTree = new TreeSet<Integer>();
          newEquivalenceTree.add(currentLabel);
          labelsEquivalences.add(newEquivalenceTree);
          currentLabel++;
        } else {
          labels[row * input.width + col] = neighbors.first();
          //mark other labels to be equivalent to each other
          for (int i : neighbors) {
            labelsEquivalences.get(i).addAll(neighbors);
          }
        }
      }
    }
  }


  // Second pass: re-label the pixels by their equivalent class
  // if onlyBiggest==true, count the number of pixels for each label

  int occurrences[] = new int[currentLabel];
  int maxLabel = 0;
  int maxLabelCount = 0;

  for (int row = 1; row < input.height - 1; row++) { // Skip left and right col
    for (int col = 1; col < input.width - 1; col++) { // Skip top & bottom row

      int curr = labels[row * input.width + col];
      if (curr != 0) {
        int newLabel = labelsEquivalences.get(curr).first();
        labels[row * input.width + col] = newLabel;
        if (onlyBiggest) {
          int occurenceNewLabel = ++occurrences[newLabel];
          if (occurenceNewLabel > maxLabelCount) {
            maxLabelCount = occurenceNewLabel;
            maxLabel = newLabel;
          }
        }
      }
    }
  }

  // Finally,
  // if onlyBiggest==false, output an image with each blob colored in one uniform color
  // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
  PImage result = createImage(input.width, input.height, RGB);
  result.loadPixels();

  //create mapping between label and color
  HashMap<Integer, Integer> m = new HashMap<Integer, Integer>();
  if (onlyBiggest) {
    m.put(maxLabel, color(255));
  } else {
    for (int i = 1; i < currentLabel; ++i) {  //FIXME assign color only to used labels
      m.put(i, color( ThreadLocalRandom.current().nextInt(1, 255), 
        ThreadLocalRandom.current().nextInt(1, 255), 
        ThreadLocalRandom.current().nextInt(1, 255)));
    }
  }

  //assign pixel value depending on mapping
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = m.getOrDefault(labels[i], color(0));
  }

  return result;
}