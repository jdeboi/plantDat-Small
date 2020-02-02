PlantFile[] buttonLeaves;
PlantFile[] buttonFlowers;


void initButton() {
  float[] scales = {0.4, 0.4, 0.35};
  boolean[] flipped = {false, false, false};
  float[] rot = {0, 0, 0};
  PVector[] snaps = {new PVector(100, 30), new PVector(70, 100), new PVector(100, 180)};

  buttonFlowers = new PlantFile[3];
  for (int i = 0; i < buttonFlowers.length; i++) {
    buttonFlowers[i] = new PlantFile("button/flower/" + i + ".svg", flipped[i], snaps[i].x, snaps[i].y, scales[i], rot[i]);
  }

  buttonLeaves = new PlantFile[1];
  buttonLeaves[0] = new PlantFile("button/leaves/" + 1 + ".svg", false, 190, 80, .3, 0);
}

class Button extends Plant {

  int numFlowers = 0;
  Button(PVector loc, float age, boolean dies) {
    this(loc, age, -1);
    this.dies = dies;
  }

  Button(PVector loc, float age, int code) {
    super(loc, age, code);
    branching = true;
    hasLeaves = true;
    growthScaler = 70;
    col = color(55, 125, 34);
  }

  void display(PGraphics s) {
    yoff += 0.005;
    //println(seed);
    randomSeed(seed);
    s.strokeWeight(1);
    s.fill(col);
    s.noStroke();
    s.pushMatrix();
    s.translate(x, y, z);
    float angle = stemAngle + windAngle/3.0;
    angle = constrain(angle, -10, 10);
    s.rotate(angle);
    s.pushMatrix();
    s.popMatrix();


    numFlowers = 0;
    numBranch = 0;
    branch(s, 0, 0, plantHeight*growthScaler, 0);
    s.popMatrix();
  }

  void leaf(int div, int num, int nn, PGraphics s) {
    s.pushMatrix();
    //s.translate(0, 0, 2);
    float leafScale = map(div, 0, 2, .8, 0.3);
    leafScale = map(num, 1, 3, leafScale, leafScale*.7);

    buttonLeaves[0].display(0, 0, 0, plantHeight*leafScale, false, s);

    s.popMatrix();
  }

  // Daniel Shiffman Nature of Code http://natureofcode.com
  void branch(PGraphics s, int div, int nn, float h, float xoff) {
    int numDivs = 3;
    numBranch++;
    // thickness of the branch is mapped to its length
    float sw = map(div, 0, numDivs, 10*plantHeight, 1);
    //s.strokeWeight(sw);
    // Draw the branch
    s.stroke(lerpColor(col, 0, .5));
    s.pushMatrix();
    s.translate(0, 0, -1*(nn+1));
    s.beginShape(QUADS);
    s.vertex(0, 0);
    s.vertex(sw, 0);
    s.vertex(sw, -h);
    s.vertex(0, -h);
    s.endShape(CLOSE);
    s.popMatrix();

    // Move along to end
    s.translate(0, -h/3);
    leaf(div, 1, nn, s);
    s.translate(0, -h/3);
    leaf(div, 2, nn, s);
    s.translate(0, -h/3);
    leaf(div, 3, nn, s);


    // Each branch will be 2/3rds the size of the previous one
    float per = 0.9;
    h *= per;
    // Move along through noise space
    xoff += 0.1;

    if (div < numDivs) {
      // Random number of branches
      float branchSpreadMax = map(div, 0, numDivs, 3, 1);
      int n = int(random(0, branchSpreadMax));

      for (int i = 0; i < n; i++) {

        // Here the angle is controlled by perlin noise
        // This is a totally arbitrary way to do it, try others!
        float thetaSpread = map(div, 0, numDivs, PI/2, PI/5);
        //float thetaSpread = PI/4;
        float theta;
        //float theta = map(noise(xoff+i, yoff), 0, 1, -thetaSpread, thetaSpread);
        if (i%2 == 0) theta =  map(noise(xoff+i, yoff), 0, 1, 0, thetaSpread);
        else theta = map(noise(xoff+i, yoff), 0, 1, -thetaSpread, 0);

        s.pushMatrix();      // Save the current state of transformation (i.e. where are we now)
        s.rotate(theta);     // Rotate by theta
        branch(s, div+1, i, h, xoff);   // Ok, now call myself to branch again
        s.popMatrix();       // Whenever we get back here, we "pop" in order to restore the previous matrix state
      }
      if (numFlowers == 0) {
        if (isFlowering) flower(s, age, true);
      }
    } else {
      if (isFlowering) flower(s, age*.6, false);
    }
  }

  void flower(PGraphics s, float stemAge, boolean needsStem) {
    int num = getFlowerIndex(stemAge);
    if (needsStem) {
      s.strokeWeight(2);
      s.line(0, 0, 0, -30*plantHeight);
      s.translate(0, -30*plantHeight);
    }
    buttonFlowers[0].display(0, 0, 0, plantHeight, false, s);
    if (num > 0) buttonFlowers[num].display(0, 0, 0, plantHeight, false, s);

    numFlowers++;
  }

  int getFlowerIndex(float stemAge) {
    int num = int(map(stemAge, bloomAge, 1, 0, buttonFlowers.length));
    num = constrain(num, 0, buttonFlowers.length-1);
    return num;
  }
}
