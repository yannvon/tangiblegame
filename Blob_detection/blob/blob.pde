import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.ThreadLocalRandom;

PImage img;

void settings() {
  size(600, 600);
}
void setup() {
  img = loadImage("BlobDetection_Test.bmp");
}
void draw() {
  background(color(0, 0, 0));
  image(img, 100, 100);
  image(findConnectedComponents(img, false), 300, 300);
  noLoop();
}

PImage findConnectedComponents(PImage input, boolean onlyBiggest) {

  // First pass: label the pixels and store labels’ equivalences

  int [] labels = new int [input.width*input.height];
  List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
  labelsEquivalences.add(new TreeSet<Integer>()); //FIXME only here to simplify access (i add a useless element at index 0, s.t. all access work later on)

  int currentLabel = 1;

  for (int col = 1; col < input.width - 1; col++) { // Skip top & bottom row
    for (int row = 1; row < input.height - 1; row++) { // Skip left and right col

      //if pixel is background don't do anything
      if (input.pixels[row * input.width + col] != color(0)) {
        TreeSet<Integer> neighbors = new TreeSet<Integer>() ;
        
        //Retain all neighbors that have a label already and save the label
        int neighbor1 = labels[(row-1) * input.width + (col-1)];
        if (neighbor1 > 0) neighbors.add(neighbor1);
        int neighbor2 = labels[(row-1) * input.width + (col)];
        if (neighbor2 > 0) neighbors.add(neighbor2);
        int neighbor3 = labels[(row-1) * input.width + (col+1)];
        if (neighbor3 > 0) neighbors.add(neighbor3);
        int neighbor4 = labels[(row) * input.width + (col-1)];
        if (neighbor4 > 0) neighbors.add(neighbor4);
        
        //Depending on neighbor value, give label to current pixel
        if (neighbors.isEmpty()) {
          labels[row * input.width + col] = currentLabel;
          labelsEquivalences.add(new TreeSet<Integer>());
          currentLabel += 1;
        } else {
          int smallestLabel = neighbors.first();
          labels[row * input.width + col] = smallestLabel;

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

  for (int col = 1; col < input.width - 1; col++) { // Skip top & bottom row
    for (int row = 1; row < input.height - 1; row++) { // Skip left and right col
      int curr = labels[row * input.width + col];
      if (curr != 0) {
        int newLabel = labelsEquivalences.get(curr).first();

        labels[row * input.width + col] = newLabel;
        if (onlyBiggest) {
          int i = ++occurrences[newLabel];
          if (i > maxLabelCount) {
            maxLabelCount = i;
            maxLabel = newLabel;
          }
        }
      }
    }
  }

  // Finally,
  // if onlyBiggest==false, output an image with each blob colored in one uniform color
  // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();

  //create mapping between label and color
  HashMap<Integer, Integer> m = new HashMap<Integer, Integer>();
  if (onlyBiggest) {
    m.put(maxLabel, color(255));
  } else {
    for (int i = 1; i < currentLabel - 1; ++i) {  //FIXME assigne color only to used labels
      m.put(i, color(ThreadLocalRandom.current().nextInt(1, 255), ThreadLocalRandom.current().nextInt(1, 255), ThreadLocalRandom.current().nextInt(1, 255)));
    }
  }
  
  //assign pixel value depending on mapping
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = m.getOrDefault(labels[i], color(0));
  }

  return result;
}