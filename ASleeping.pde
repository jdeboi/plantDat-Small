PlantFile[] sleepingFlowers;
PlantFile[] sleepingLeaves;



void initSleeping() {  

  float[] scales = {0.1, 0.05};
  boolean[] flipped = {false, false};
  float[] rot = {0, 0, 0};
  PVector[] snaps = {new PVector(100, 150), new PVector(400, 1450)};

  sleepingFlowers = new PlantFile[2];
  sleepingLeaves = new PlantFile[2];
  sleepingLeaves[0] = new PlantFile("sleeping/leaves/0.svg", true, 80, -20, 0.8, radians(-140));
  sleepingLeaves[1] = new PlantFile("sleeping/leaves/1.svg", true, 220, 20, 0.4, radians(-140));

  for (int i = 0; i < sleepingFlowers.length; i++) {
    sleepingFlowers[i] = new PlantFile("sleeping/flower/" + i + ".svg", flipped[i], snaps[i].x, snaps[i].y, scales[i], rot[i]);
  }
}


class Sleeping extends Stokes {


  Sleeping(PVector loc, float age, boolean dies) {
    this(loc, age, -1);
    this.dies = dies;
  }

  Sleeping(PVector loc, float age, int code) {
    super(loc, age, code);

    col = color(#4EBD00);
  }

  void display(PGraphics s) {
    //s.stroke(col);
    s.pushMatrix();
    s.translate(x, y, z);
    float angle = stemAngle + windAngle/3.0;
    angle = constrain(angle, -10, 10);
    s.rotate(angle);

    numBranch = 0;
    totLen = leafSpacing;
    currentLen = leafSpacing;

    s.stroke(0);
    s.fill(col);
    stem(s, plantHeight*growthScaler, 0, age, stemStroke);

    s.popMatrix();
  }

  @Override
    void displayFlower(float stemAge, PGraphics s) {
    sleepingFlowers[getFlowerIndex(stemAge)].display(0, 0, 0, plantHeight, false, s);
  }

  void leaf(int segment, PGraphics s) {
    //super.leaf(segment, s);
    s.pushMatrix();
    s.translate(0, 0, (5-segment));
    float leafScale = map(segment, 0, 5, .7, 0.1);
    float r = radians(0); //-90
    float factor = plantHeight*leafScale;
    float w= 35*factor;
    float h =5*factor;
    if (numBranch == 1) {

      s.pushMatrix();
      s.rotate(radians(-45));
      s.rect(0, -h/2, w, h);
      s.popMatrix();
      sleepingLeaves[pID%2].display(0, 0, r, factor, true, s);
    }
    if (numBranch == 2) {
      s.pushMatrix();
      s.rotate(radians(-135));

      s.rect(0, -h/2, w, h);
      s.popMatrix();
      sleepingLeaves[(pID+1)%2].display(0, 0, r, plantHeight*leafScale, false, s);
    }
    if (numBranch % 5 == 3) {
      sleepingLeaves[(pID)%2].display(0, 0, r, plantHeight*leafScale, true, s);
      s.pushMatrix();
      s.rotate(radians(-45));
      s.rect(0, -h/2, w, h);
      s.popMatrix();
    }
    if (numBranch % 5 == 4) {
      s.pushMatrix();
      s.rotate(radians(-135));
       s.rect(0, -h/2, w, h);
      s.popMatrix();
      sleepingLeaves[(pID+1)%2].display(0, 0, r, plantHeight*leafScale, false, s);
    } 
    s.popMatrix();
  }

  @Override
    int getFlowerIndex(float stemAge) {
    int num = int(map(stemAge, bloomAge, 1, 0, 2));
    num = constrain(num, 0, 1);
    return num;
  }
}
