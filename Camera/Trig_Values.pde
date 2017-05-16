class Trig {
  // pre-compute the sin and cos values
  int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];

  // --- Week 12: Optimisation ---
  // pre-compute the sin and cos values

  public Trig() {
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;

    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
  }
}