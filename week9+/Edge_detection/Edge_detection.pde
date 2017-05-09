import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.ThreadLocalRandom;

PImage img;
PImage imgCorrect;

HScrollbar thresholdBar1;
HScrollbar thresholdBar2;
HScrollbar thresholdBar3;

void settings() {
  size(1600, 600);
}
void setup() {
  img = loadImage("board1.jpg");
  imgCorrect = loadImage("board1Scharr.bmp");
  thresholdBar1 = new HScrollbar(0, 580, 800, 20);
  thresholdBar2 = new HScrollbar(800, 540, 800, 20);
  thresholdBar3 = new HScrollbar(800, 580, 800, 20);
  println(imagesEqual(scharr(img), imgCorrect));
  noLoop();
}
void draw() {
  background(color(0, 0, 0));

  //Brighness filtering imag
  float thresh = 255 * thresholdBar1.getPos();
  PImage imgB = thresholdBrightness(img, (int) thresh);
  // image(imgB, 0, 0);
  image(pipeline(img), 0, 0);
  //Hue filtering image
  float tLow = 255 * thresholdBar2.getPos();
  float tHigh = 255 * thresholdBar3.getPos();
  PImage imgHue = thresholdHue(img, (int) tLow, (int) tHigh);
  image(imgHue, img.width, 0);

  thresholdBar1.display();
  thresholdBar2.display();
  thresholdBar3.display();
  thresholdBar1.update();
  thresholdBar2.update();
  thresholdBar3.update();

  //PImage imgFinal = thresholdHSB(img, 100, 200, 100, 255, 45, 100);
  //println(imagesEqual(imgFinal, imgCorrect));
}

PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    color c = img.pixels[i];
    int value = (minB <= brightness(c) && brightness(c) <= maxB &&
      minH <= hue(c) && hue(c) <= maxH &&
      minS <= saturation(c) && saturation(c) <= maxS) ? 255 : 0;
    result.pixels[i] = color (value, value, value);
  }
  return result;
}

PImage thresholdHue(PImage img, int tLow, int tHigh) {
  // create a new, initially transparent, ’result’ image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    float hue = hue(img.pixels[i]);
    if (hue >= tLow && hue <= tHigh) {
      result.pixels[i] = color(img.pixels[i]);
    } else {
      result.pixels[i] = color(0, 0, 0);
    }
  }
  return result;
}

PImage thresholdBrightness(PImage img, int threshold) {
  // create a new, initially transparent, ’result’ image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i]) >= threshold) {
      result.pixels[i] = color(255, 255, 255);
    } else {
      result.pixels[i] = color(0, 0, 0);
    }
  }
  return result;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i]))
      return false;
  return true;
}

PImage convolute(PImage img) {
  float[][] kernel = { { 9, 12, 9 }, 
    { 12, 15, 12 }, 
    { 9, 12, 9 }};
  float normFactor = 99.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);

  //kernel size
  int N = 3;
  //
  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by normFactor
  // - set result.pixels[y * img.width + x] to this value
  for (int x = 1; x < img.width - 1; ++x) {
    for (int y = 1; y < img.height - 1; ++y) {
      float sum = 0.0;
      for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
          sum += brightness(img.pixels[x - N/2 + i + (y-N/2+j)*img.width]) * kernel[i][j];
        }
      }
      result.pixels[y * img.width + x] = color(sum/normFactor);
    }
  }
  return result;
}

PImage scharr(PImage img) {
  float[][] vKernel = {
    { 3, 0, -3 }, 
    { 10, 0, -10 }, 
    { 3, 0, -3 } };
  float[][] hKernel = {
    { 3, 10, 3 }, 
    { 0, 0, 0 }, 
    { -3, -10, -3 } };
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];
  // *************************************
  //kernel size
  int N = 3;
  for (int x = 1; x < img.width - 1; ++x) {
    for (int y = 1; y < img.height - 1; ++y) {
      float sumH = 0.0;
      float sumV = 0.0;
      for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
          sumH += brightness(img.pixels[x - N/2 + i + (y-N/2+j)*img.width]) * hKernel[i][j];
          sumV += brightness(img.pixels[x - N/2 + i + (y-N/2+j)*img.width]) * vKernel[i][j];
        }
      }
      float sum=sqrt(pow(sumH, 2) + pow(sumV, 2));
      if (sum>max)max = sum;
      buffer[y * img.width + x] = sum;
    }
  }
  // *************************************
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      int val=(int) ((buffer[y * img.width + x] / max)*255);
      result.pixels[y * img.width + x]=color(val);
    }
  }
  return result;
}

PImage pipeline(PImage img) {
  return scharr(thresholdBrightness(convolute(findConnectedComponents(thresholdHSB(img, 50, 143, 100, 255, 50, 170), true)), 100));
}

//blob detection
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