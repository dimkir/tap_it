public class Intro {
  /* This class has a timer which is started when the class is constructed. 
   The class can display itself and check to see if it has been pressed */


  private int nImgTarget = 30;
  private int nMatches = 4;
  private int nImg;

  private float borderSize = .075; // * width, * height

  private float[] x;
  private float[] y;
  private float imgW;
  private float imgH;
  private float padding = .25;

  private int[] imgIndices;
  private ArrayList<Integer> matchPositions;

  // variables for jiggling images
  private float[] dx;
  private float[] dy;
  private float[] a;

  // variables to control acceleration of jiggling and bound it
  private float ddp = .0003;
  private float dpMax = .01;

  private float textSize = .225; // * height
  private float titleX = .5; // * width
  private float titleY = .4; // * height

  // variables to control highlighting matched symbols
  private Timer timer;
  private int titleTime = 1800;
  private int matchTime = 1500;
  private float matchSizeMultiplier = 1.5;

  private boolean titleFinished;


  /******** no argument constructor, everything is implemented within the class ********/
  public Intro() {

    textSize *= height;
    titleX *= width;
    titleY *= height;

    /********* Compute numbers of images to be shown *********/
    float w = width * (1 - borderSize);
    float h = height * (1 - borderSize);

    int ratio = round(w / h);
    int nVertical = round(sqrt(nImgTarget / (float) ratio));
    int nHorizontal = nVertical * ratio;

    nImg = nVertical * nHorizontal;



    /********* Compute image dimensions and locations *********/
    x = new float[nImg];
    y = new float[nImg];
    for (int i = 0; i < nImg; i++)
      x[i] = w * (i % nHorizontal + 1) / (nHorizontal + 1) + (borderSize / 2.0) * width;
    for (int j = 0; j < nImg; j++) 
      y[j] = h * (j / nHorizontal + 1) / (nVertical + 1) + (borderSize / 2.0) * height;

    imgW = (w / ((float) nHorizontal + 1)) * (1 - padding);
    imgH = (h / ((float) nVertical + 1)) * (1 - padding);


    /********* Choose nImg - nMatches random imgIndices *********/
    ArrayList<Integer> indicesToShuffle = new ArrayList<Integer>();
    for (int i = 0; i < 100; i++)
      indicesToShuffle.add(i);
    Collections.shuffle(indicesToShuffle);

    imgIndices = new int[nImg];
    for (int i = 0; i < imgIndices.length - nMatches; i++)
      imgIndices[i] = indicesToShuffle.get(i);


    /********* Choose nMatches indices which have already been chosen and shuffle 
     them into imgIndices, also save indices of matches *********/
    ArrayList<Integer> matchIndices = new ArrayList<Integer>();
    for (int i = imgIndices.length - nMatches; i < imgIndices.length; i++) {
      imgIndices[i] = imgIndices[i - (imgIndices.length - nMatches)];
      matchIndices.add(imgIndices[i]);
    }

    // reuse indices ArrayList instantiated above to call Collections.shuffle()
    indicesToShuffle = new ArrayList<Integer>();
    for (int i = 0; i < imgIndices.length; i++)
      indicesToShuffle.add(imgIndices[i]);
    Collections.shuffle(indicesToShuffle);

    // put shuffled indices with matches back into imgIndices
    for (int i = 0; i < imgIndices.length; i++)
      imgIndices[i] = indicesToShuffle.get(i);


    /********* Find positions of matches, keep pair of positions for a given match adjacent *********/
    matchPositions = new ArrayList<Integer>();
    for (int j = 0; j < matchIndices.size(); j++) {
      int matchIndex = matchIndices.get(j);
      for (int i = 0; i < imgIndices.length; i++)
        if (imgIndices[i] == matchIndex)
          matchPositions.add(i);
    }


    /********* Initialize jiggling variables *********/
    dx = new float[nImg];
    dy = new float[nImg];
    a = new float[nImg];

    for (int i = 0; i < nImg; i++)
      a[i] = random(0, 2 * PI);

    timer = new Timer(0);
    timer.start();
    titleFinished = false;
  }




  public void display() {

    background(0);
    imageMode(CENTER);


    /***** Check for whether title screen is finished *****/
    int currentTime = timer.elapsedTime();
    if (currentTime >= titleTime && !titleFinished) {
      timer = new Timer(0);
      timer.start();
      titleFinished = true;
    }


    /***** display all matched images *****/
    for (int i = 0; i < nImg; i++) {

      updateImg(i); // make images jiggle
      pushMatrix();
      translate(dx[i] * width + x[i], dy[i] * height + y[i]);
      rotate(a[i]);

      // if title isn't finished yet, display images in background but don't highlight matches
      if (!titleFinished)
        image(allImgs[imgIndices[i]], 0, 0, imgW, imgH);

      // highlight matches
      else 
      {
        int currentMatch = (currentTime / matchTime) % nMatches;
        int matchPositionA = matchPositions.get(2 * currentMatch); // indices of current matched pair of symbols
        int matchPositionB = matchPositions.get(2 * currentMatch + 1);

        float tintStrength = 255 * abs(sin(1.0 * PI * currentTime / (float) matchTime));

        if (matchPositionA == i || matchPositionB == i) {
          tint(255 - tintStrength, 255, 255 - tintStrength);
          image(Tap_It.imageAtIndex(imgIndices[i]), 0, 0, imgW * matchSizeMultiplier, imgH * matchSizeMultiplier);
        }
        else {
          noTint();
          image(Tap_It.imageAtIndex(imgIndices[i]), 0, 0, imgW, imgH);
        }
      }

      popMatrix();
    }


    /***** display game title until it disappears *****/
    if (!titleFinished) {
      textAlign(CENTER, CENTER);
      textSize(textSize);

      float transparency = currentTime / (float) titleTime;

      rectMode(CORNER);
      fill(0, 255 * sqrt(sqrt(1 - transparency)));
      rect(0, 0, width, height);

      fill(255, 255, 0, 255 * sqrt(1 - transparency));
      text(Tap_It.DISPLAY_NAME, titleX, titleY);
      textAlign(LEFT, BASELINE);
    }
  }



  // helper function for making images jiggle
  private void updateImg(int index) {
    dx[index] += random(-ddp, ddp);
    dx[index] = constrain(dx[index], -dpMax, dpMax);

    dy[index] += random(-ddp, ddp);
    dy[index] = constrain(dy[index], -dpMax, dpMax);
  }



  // return true if screen is pressed anywhere, this is simply to dereference Intro object
  public boolean checkClick() {
    noTint(); // remove tint so that it doesn't carry over into game when intro is dereferenced
    return true;
  }
}

