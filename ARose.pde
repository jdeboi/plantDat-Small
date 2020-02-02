PlantFile[] roseLeaves;
PlantFile[] roseFlowers;

void initRose() {
  float[] roseScales = {0.2, 0.2, 0.3};
  boolean[] roseFlipped = {false, false, false};
  float[] roseRot = {0, 0, 0};
  PVector[] roseSnaps = {new PVector(130, 400), new PVector(230, 630), new PVector(230, 450)};

  roseFlowers = new PlantFile[3];
  for (int i = 0; i < roseFlowers.length; i++) {
    roseFlowers[i] = new PlantFile("rosemallow/flower/" + i + ".svg", roseFlipped[i], roseSnaps[i].x, roseSnaps[i].y, roseScales[i], roseRot[i]);
  }

  float[] roseScalesL = {0.3};
  boolean[] roseFlippedL = {false};
  float[] roseRotL = {radians(0)};
  PVector[] roseSnapsL = {new PVector(250, 60)};

  roseLeaves = new PlantFile[1];
  for (int i = 0; i < roseLeaves.length; i++) {
    roseLeaves[i] = new PlantFile("rosemallow/leaves/" + i + ".svg", roseFlippedL[i], roseSnapsL[i].x, roseSnapsL[i].y, roseScalesL[i], roseRotL[i]);
  }
}

class Rose extends Obedient {



  Rose(PVector loc, float age, boolean dies) {
    this(loc, age, -1);
    this.dies = dies;
  }

  Rose(PVector loc, float age, int code) {
    super(loc, age, code);
    //leaves = new ArrayList<BeautyLeaf>();
  }

  void flower(PGraphics s, float stemAge) {
    if (stemAge > bloomAge) isFlowering = true;
    else isFlowering = false;
    isFlowering = true;
    s.pushMatrix();
    s.translate(0, 0, 2);
    if (isFlowering) roseFlowers[getFlowerIndex(stemAge)].display(0, 0, 0, plantHeight, false, s);
    s.popMatrix();
  }

  @Override
    int getFlowerIndex(float stemAge) {
    int num = int(map(stemAge, bloomAge, 1, 0, roseFlowers.length));
    num = constrain(num, 0, roseFlowers.length-1);
    return num;
  }

  void leaf(int segment, PGraphics s) {
    float scal = map(numBranch, 0, 15, 1.0, .3)*plantHeight;
    float leafScale = map(segment, 0, numSegments, 1.0, 0.4);
    if (segment > 0) {
      roseLeaves[0].display(0, 0, 0, scal*leafScale, false, s);
    }
    if (segment < 4) {
      s.pushMatrix();
      s.translate(0, -plantHeight*20);
      roseLeaves[0].display(0, 0, 0, scal*leafScale, true, s);
      s.popMatrix();
    }
  }
  
  @Override 
   color getStemStroke() {
    return color(0, 50, 0);
  }
  
  @Override
   color getStemFill(int numBranch) {
    return lerpColor(color(0, 80, 0), color(0, 150, 0), map(numBranch, 0, 10, 0, 1));
  }
}
