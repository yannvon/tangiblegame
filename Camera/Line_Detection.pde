// Comparator
class HoughComparator implements java.util.Comparator<Integer> {
  int[] accumulator;
  public HoughComparator(int[] accumulator) {
    this.accumulator = accumulator;
  }
  @Override
    public int compare(Integer l1, Integer l2) {
    if (accumulator[l1] > accumulator[l2]
      || (accumulator[l1] == accumulator[l2] && l1 < l2)) return -1;
    return 1;
  }
}
// --- Week 12: Optimisation ---
// pre-compute the sin and cos values
float[] tabSin = new float[phiDim];
float[] tabCos = new float[phiDim];

float ang = 0;
float inverseR = 1.f / discretizationStepsR;

for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
  // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
  tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
  tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
}


//--- Week ??: hough transform ---
ArrayList<PVector> hough(PImage edgeImg, int nlines, int regionRadius) {

  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi +1);

  //The max radius is the image diagonal, but it can be also negative
  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
    edgeImg.height * edgeImg.height) * 2) / discretizationStepsR +1);

  // our accumulator
  int[] accumulator = new int[phiDim * rDim];

  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {

      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator: r += rDim / 2
        for (int phiN = 0; phiN < phiDim; phiN++) {

          float phi = phiN * discretizationStepsPhi;
          float r = (x * cos(phi) + y * sin(phi));

          r = r/discretizationStepsR;
          r += rDim / 2;

          //increment corresponding accumulator
          accumulator[phiN * rDim + (int) r] += 1;
        }
      }
    }
  }

  // --- Week 12: Line Selection ---
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  for (int idx = 0; idx < accumulator.length; idx++) {
    int value = accumulator[idx];

    //STEP 1: take only the most voted lines
    if (value > minVotes) {
      //STEP 2: take only maxima of region
      boolean maxima = true;
      for (int x = -regionRadius; x <= regionRadius; x++) {
        for (int y = -regionRadius; y <= regionRadius; y++) {
          int index = y * edgeImg.width + x + idx;
          if (index > 0 && index < accumulator.length && accumulator[index] > value) maxima = false;
        }
      }
      if (maxima) bestCandidates.add(idx);
    }
  }
  //STEP 3: sort the promising lines
  Collections.sort(bestCandidates, new HoughComparator(accumulator));

  //STEP 4: take as many lines as asked and compute the line parameters
  ArrayList<PVector> lines = new ArrayList<PVector>();
  for (int i = 0; i < nlines && i < bestCandidates.size(); i++) {
    int idx = bestCandidates.get(i);
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / (rDim));
    int accR = idx - (accPhi) * (rDim);
    float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    lines.add(new PVector(r, phi));
  }

  //TODO remove following part
  // --- Optional: Create an image of the accumulator ---
  PImage houghImg = createImage(rDim, phiDim, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }

  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(600, 600);
  houghImg.updatePixels();

  //image(houghImg, houghImg.width, 0);

  return lines;
}

// --- Method to display lines on ---
void plotLines(PImage edgeImg, List<PVector> lines) {

  for (int idx = 0; idx < lines.size(); idx++) {
    PVector line = lines.get(idx);
    float r = line.x;
    float phi = line.y;

    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)

    // compute the intersection of this line with the 4 borders of the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }
}