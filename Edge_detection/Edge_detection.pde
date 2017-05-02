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
      if(sum>max)max = sum;
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

PImage pipeline(PImage img){
    return scharr(thresholdBrightness(convolute(thresholdHSB(img, 50, 143, 135, 255, 50, 170)), 100));
}