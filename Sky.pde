int rainLasts = 1*60*1000;
int sunLasts = 1*60*1000;
long lastRainTime = 0;


PImage houses;
PShape housesSvg;
PShape wires;
PShape skyline;
PShape backhouses;

PImage cement;
PlantFile[] concrete;


PImage plants[];

boolean isRaining = true;
boolean thunder = false;
boolean  thundering = false;
long lastThundering = 0;
long lastThunder = 0;
int thunderNum = 0;
long ranTime = 0;
int tTime = 20;

float windAngle = 0;
float windNoise = 0;


color startDayColor, midDayColor, endDayColor;


import ddf.minim.*;
Minim minim;
AudioPlayer thunderSound;
AudioPlayer rainSound;
AudioPlayer windSound;

boolean rainEnding = false;

void playSounds() {
  if (thundering) {
    if (!thunderSound.isPlaying()) thunderSound.play(0);
    rainSound.setGain(0);
    windSound.setGain(-100);
  }
  if (isRaining) {
    // this will work as long as the rain soundfile is longer than the time rain lasts
    if (!rainSound.isPlaying()) rainSound.play(0);
    if (millis() - lastRainTime > rainLasts - 4000) {
      rainSound.shiftGain(rainSound.getGain(), -100, 4000);
      windSound.setGain(-4);
    }
  }
}

void stop() {
  windSound.close();
  thunderSound.close();
  rainSound.close();
  minim.stop();
}



color getBackground() {
  if (thunder) {
    return color(255);
  }
  return getBackgroundHue();
}

color getBackgroundHue() {
  color c;
  long timeP = millis() - lastRainTime;
  if (timeP < rainLasts*.7) {
    c = color(50);
  } else if (timeP < rainLasts) {
    float per = map(timeP, rainLasts*.7, rainLasts, 0, 1);
    c = lerpColor(color(50), endDayColor, per);
  } else if (timeP < rainLasts + sunLasts *.7) {
    c = endDayColor;
  } else {
    float per = map(timeP, rainLasts + sunLasts *.7, rainLasts + sunLasts, 0, 1);
    c = lerpColor(endDayColor, color(50), per);
    //println("not raining but getting closer");
  }
  return c;
}

void checkThunder() {
  if (isRaining) {
    // if it's about to stop raining, let's just not thunder
    if ( millis() - lastRainTime > rainLasts - 7000) {
      thundering = false;
      thunder = false;
    } else if (!thundering) {
      if (millis() - lastThundering > ranTime) {
        thundering = true;
        lastThundering = millis();
      }
    } else if (thundering) {
      if (!thunder) {
        if (thunderNum == 0) {
          thunder = true;
          lastThunder = millis();
          thunderNum++;
          tTime += 50;
        } else if (millis() - lastThunder > 50) {
          thunder = true;
          lastThunder = millis();
        }
      } else if (thunder) {
        if (millis() - lastThunder > tTime) {
          lastThunder = millis();
          thunder = false;
          thunderNum++;
          if (thunderNum == 5) {
            thundering = false;
            thunderNum = 0;
            tTime = 20;
            lastThundering = millis();
            ranTime = int(random(8000, 16000));
          }
        }
      }
    }
  } else {
    thundering = false;
    thunder = false;
  }
}

void initBackground() {
  plantColor = color(#11BB7C);
  stemStroke = color(0, 50, 0);
  startDayColor = color(#BCF5FF);
  midDayColor = color(#FFB4EE);
  endDayColor = color(#6965D6);

  //houses = loadImage("images/houses.png");

  housesSvg = loadShape("images/houses4.svg");
  wires = loadShape("images/wires2.svg");
  skyline = loadShape("images/skyline2.svg");
  backhouses = loadShape("images/backhouses2.svg");


  minim = new Minim(this);
  thunderSound = minim.loadFile("sounds/thunderSound.mp3");
  rainSound = minim.loadFile("sounds/rainSound.mp3");
  windSound = minim.loadFile("sounds/windSound.mp3");
  windSound.loop();
}

void displayHouse(PGraphics s, int z ) {
  s.pushMatrix();

  float w = s.width*2.8;
  float down = -s.height*.75;
  //float factor = w/houses.width;
  //float h = houses.height*factor;






  s.translate(-w*.3, down, z);
  s.pushMatrix();

  s.rotate(radians(0));
  //s.image(houses, 0, 0, w, h);
  s.translate(-400, -320);
  float factor = 1.6;
  s.translate(-80, -20, -2);
  s.noStroke();
  skyline.disableStyle();
  s.fill(lerpColor(getBackgroundHue(), color(255), .1));
  s.shape(skyline, 0, 0, skyline.width*factor, skyline.height*factor);
  s.translate(0, 0, .5);
  backhouses.disableStyle();
  s.fill(lerpColor(getBackgroundHue(), color(255), .3));
  s.shape(backhouses, 0, 0, backhouses.width*factor, backhouses.height*factor);


  s.translate(0, 0, .5);
  displayCement(s, 0, 0); //down*1.35

  s.translate(0, 0, .5);
  s.shape(wires, 0, 0, wires.width*factor, wires.height*factor);

  s.translate(0, 20, .5);
  s.noStroke();
  //housesSvg.enableStyle();
  s.shape(housesSvg, 0, 0, housesSvg.width*factor, housesSvg.height*factor);


  s.popMatrix();

  //s.pushMatrix();
  //s.translate(s.width*.6, 0);
  //s.rotate(radians(0));
  //s.image(shotgun2, 0, 0, w, h);
  //s.popMatrix();



  s.popMatrix();
}


void checkRain() {

  if (millis() - lastRainTime < rainLasts) {
    isRaining = true;
  } else {
    isRaining = false;
  }

  if (millis() - lastRainTime > rainLasts + sunLasts) {
    lastRainTime = millis();
  }
}

//void displaySky(PGraphics s) {
//  s.noStroke();
//  for (int i = 0; i < 5; i++) {
//    s.pushMatrix();
//    s.translate(-s.width*2 + i*s.width, -200, -800);
//    color c1 = color(#6965D6);
//    color c2 = color(#FFADFB);
//    color c3 = color(#FFDAAD);

//    float per = 0.6;
//    int screenH = int(s.height*2.5);
//    s.beginShape();
//    s.fill(c1);
//    s.vertex(0, 0);
//    s.vertex(s.width, 0);
//    s.fill(c2);
//    s.vertex(s.width, screenH*per);
//    s.vertex(0, screenH*per);
//    s.endShape();

//    s.beginShape();
//    s.fill(c2);
//    s.vertex(0, screenH*per);
//    s.vertex(s.width, screenH*per);
//    s.fill(c3);
//    s.vertex(s.width, screenH);
//    s.vertex(0, screenH);
//    s.endShape();
//    s.popMatrix();
//  }

//  displayHouse(s, -1300);
//}

void displayCement(PGraphics s, float y, int z) {
  int gradStarts = 220;
  s.pushMatrix();
  s.translate(-s.width*2, y+650, z);
  displayGradientCement(s, gradStarts, y, z);

  if (breaking) {
    s.fill(200);
    s.rect(-s.width, 0, s.width*7, s.height*6);
  } else s.rect(-s.width, gradStarts, s.width*7, s.height*2);
  s.popMatrix();
}

void displayGradientCement(PGraphics s, int gradStarts, float y, int z) {
  s.noStroke();
  s.beginShape();
  color c1 = lerpColor(getBackgroundHue(), color(255), .4);
  s.fill(lerpColor(cementColor, c1, .7));
  s.vertex(-s.width, 0, 0, 0);
  float inc = 0;
  for (int i = -s.width; i <= s.width*6; i+= 50) {
    //s.fill((i+s.width)*1.0/(s.width*7) * 255);
    s.vertex(i, noise(inc += 0.05)*50, (i+s.width)*1.0/(s.width*7), 0);
  }
  s.fill(cementColor);
  s.vertex(s.width*6, gradStarts, 1, 0);
  //s.vertex(s.width*6, s.height*2, 1, 1);
  //s.vertex(-s.width, s.height*2, 0, 1);
  s.vertex(-s.width, gradStarts, 0, 0);
  s.endShape();
}

void initCement() {
  concrete = new PlantFile[4];

  float[] scales = {1, 1, 1, 1};
  boolean[] flipped = {false, false, false, false};
  float[] rot = {radians(90), radians(90), radians(90), radians(90)};
  PVector[] snaps = {new PVector(90, 100), new PVector(160, 180), new PVector(200, 300), new PVector(350, 500)};
  for (int i = 0; i < 4; i++) {
    concrete[i] = new PlantFile("images/concrete/" + i + ".svg", flipped[i], snaps[i].x, snaps[i].y, scales[i], rot[i]);
  }
}

void displayCementBreaking(PGraphics s) {
  if (breakingNum > 0 && breakingNum < 5) {
    //s.shape(concrete[breakingNum-1], 0, 0);
    concrete[breakingNum-1].display(s.width/2, s.height*2.0/3, 0, 1, false, s);
  }
}



boolean getRaining() {
  if (millis() - lastRainTime < rainLasts) {
    return true;
  }
  return false;
}


Drop[] drops = new Drop[150]; // array of drop objects

void initDrops(PGraphics s) {
  for (int i = 0; i < drops.length; i++) { // we create the drops 
    drops[i] = new Drop(s);
  }
}


class Drop {
  float x; // x postion of drop
  float y; // y position of drop
  float z; // z position of drop , determines whether the drop is far or near
  float len; // length of the drop
  float yspeed; // speed of te drop
  float yMin = 4;
  float yMax = 15;

  //near means closer to the screen , ie the higher the z value ,closer the drop is to the screen.
  Drop(PGraphics s) {
    x  = random(s.width); // random x position ie width because anywhere along the width of screen
    y  = random(-500, -50); // random y position, negative values because drop first begins off screen to give a realistic effect
    z  = random(0, 20); // z value is to give a perspective view , farther and nearer drops effect
    len = map(z, 0, 20, 5, 12); // if z is near then  drop is longer
    yspeed  = map(z, 0, 20, yMin, yMax); // if z is near drop is faster
  }

  void fall(PGraphics s) { // function  to determine the speed and shape of the drop 
    y = y + yspeed; // increment y position to give the effect of falling 
    float grav = map(z, 0, 20, 0, 0.2); // if z is near then gravity on drop is more
    yspeed = yspeed + grav; // speed increases as gravity acts on the drop

    if (y > s.height-z*30) { // repositions the drop after it has 'disappeared' from screen
      y = random(-200, -100);
      yspeed = map(z, 0, 20, yMin, yMax);
    }
  }

  void fall() { // function  to determine the speed and shape of the drop 
    y = y + yspeed; // increment y position to give the effect of falling 
    float grav = map(z, 0, 20, 0, 0.2); // if z is near then gravity on drop is more
    yspeed = yspeed + grav; // speed increases as gravity acts on the drop

    if (y > height) { // repositions the drop after it has 'disappeared' from screen
      y = random(-200, -100);
      yspeed = map(z, 0, 20, yMin, yMax);
    }
  }

  void show(PGraphics s) { // function to render the drop onto the screen
    float thick = map(z, 0, 20, 1, 3); //if z is near , drop is more thicker 
    s.strokeWeight(thick); // weight of the drop
    s.stroke(155); // purple color
    s.line(x, y, x, y+len); // draws the line with two points
  }

  void show() { // function to render the drop onto the screen
    float thick = map(z, 0, 20, 1, 3); //if z is near , drop is more thicker 
    strokeWeight(thick); // weight of the drop
    stroke(155); // purple color
    line(x, y, x, y+len); // draws the line with two points
  }
}



void rain(float amt, PGraphics s) {
  for (int i = 0; i < drops.length; i+= amt) {
    drops[i].fall(s); // sets the shape and speed of drop
    drops[i].show(s); // render drop
  }
}

void rain(float amt) {
  for (int i = 0; i < drops.length; i+= amt) {
    drops[i].fall(); // sets the shape and speed of drop
    drops[i].show(); // render drop
  }
}

void displayRain(PGraphics s) {
  if (isRaining) {
    float amt = 1;
    if (millis() - lastRainTime > rainLasts *.8) amt = map(millis()-lastRainTime, rainLasts*.7, rainLasts, 1, 8);
    rain(amt, s);
  }
}

void displayRain() {
  if (isRaining) {
    float amt = 1;
    if (millis() - lastRainTime > rainLasts *.8) amt = map(millis()-lastRainTime, rainLasts*.7, rainLasts, 1, 8);
    rain(amt);
  }
}



void wind() {
  //float windForce = map(mouseX, 0, width, -PI/7, PI/7);
  float windForce = map(noise(0, flyingTerr), 0, 1, -PI/15, PI/15);
  //windAngle =  windForce + windForce/4 * 2*PI * sin(mouseX/1000.0);
  windAngle =  windForce + windForce/4 *sin(map(noise(0, flyingTerr), 0, 1, 0, width)/1000.0);
}
