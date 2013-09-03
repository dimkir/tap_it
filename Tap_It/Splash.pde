public class Splash {

  /************************************
   This class is manages the flow of the game. It knows which state the game is in, and
   in each call to draw() the main routine queries this class so it knows whether to display
   and update the Player (i.e. the game), the Scores, or Splash. It has getters and setters
   for booleans that flag which state the game is in. If inPlay and inScores must not both
   be true at the same time. If neither is true, then the main routine displays and updates Splash
   ************************************/

  private boolean inWait;
  private boolean inPlay;
  private boolean inScores;
  private Slider spc;
  private Slider mode;

  private PImage bgImg; // this background image
  private final color BG = color(0); // background color in absence of background image

  private float textSizeStart = .13; // * height
  private float textSizeScores = .055; // * height

  // coordinates for text on screen, coordinates for sliders ARE HARD-CODED BELOW IN CONSTRUCTOR
  private float startX = .48; // * width
  private float startY = .22; // * height
  private float scoresX = .85;
  private float scoresY = .875;
  private int opaqueness = 200; // out of 255


  private Integer[] symbolNumbers = Tap_It.spcNumbers;
  private String[] modes = Tap_It.modes;

  private int spcInt;
  private String modeString;


  // constrcutor, instantiates sliders and sets inScreen booleans to be false
  public Splash() {
    textSizeStart *= height;
    textSizeScores *= height;

    startX *= width;
    startY *= height;
    scoresX *= width;
    scoresY *= height;

    inWait = false;
    inPlay = false;
    inScores = false; 

    spc = new Slider(round(.25 * width), round(.5 * height), round(.25 * width), round(.11 * height), 
    symbolNumbers, Tap_It.spcInitialIndex, "Images");

    mode = new Slider(round(.66 * width), round(.5 * height), round(.1 * height), round(.13 * height), 
    modes, Tap_It.modeInitialIndex, "");
  } 


  // various getters and setters
  public boolean inWait() {
    return inWait;
  }

  public boolean inPlay() {
    return inPlay;
  }

  public boolean inScores() {
    return inScores;
  }


  public void setWaitStatus(boolean inWait) {
    this.inWait = inWait;
  }

  public void setGameStatus(boolean inPlay) {
    this.inPlay = inPlay;
  }

  public void setScoresStatus(boolean inScores) {
    this.inScores = inScores;
  }


  // set the background of the splash screen
  public void setBackground(PImage bgImg) {
    this.bgImg = bgImg;
  }

  // get states of the various sliders that control game variables
  public int spc() {
    return spcInt;
  }

  public String mode() {
    return modeString;
  }



  public void displayAndUpdate() {

    if (bgImg == null)
      background(BG);
    else
      background(bgImg);

    rectMode(CORNER);
    fill(0, opaqueness); // mostly background of previous game partially visible
    rect(0, 0, width, height);

    fill(255);

    textAlign(CENTER, CENTER);
    textSize(textSizeStart);
    text("Start", startX, startY);
    textSize(textSizeScores);
    text("Scores", scoresX, scoresY);
    textAlign(LEFT, BASELINE); // reset to default

    spc.update();
    mode.update();

    spc.display();
    mode.display();

    spcInt = (Integer) spc.getValue();
    modeString = (String) mode.getValue();
  }



  /* splash screen is checking for a click to initialize a new game (go to player screen)
   or go to scores screen */
  public int checkClick() {
    if (inPlay || inScores || inWait) // return unless game is actually in splash screen
      return -1;

    if (dist(mouseX, mouseY, startX, startY) < 1.25 * textSizeStart) {
      inWait = true;
      return 0;
    }

    if (dist(mouseX, mouseY, scoresX, scoresY) < 1.25 * textSizeScores) {
      inScores = true;
      return 1;
    }

    return -1;
  }
}

