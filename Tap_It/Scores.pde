public class Scores {

  private String path;
  private String[] scores;
  private final String BLANK = "--   --"; // this means the high score here is blank
  private final int NSCORES = 20; 
  // this is the number of high scores that can be stored for a given mode, must be even

  private final color BG = color(0);
  private final color TEXTCOLOR = color(255);
  private String mode;
  private int spc;

  private float textSize;
  private float column1x = .325; // * width
  private float column2x = .675;

  private boolean inErase; // is scores screen in the erase confirmation screen?
  private float eraseTextSize = .065; // * height
  private float eraseX = .1; // * width
  private float eraseY = .875; // * height
  private float confirmTextSize = .1; // * height
  private float noX = .625; // * width
  private float noY = .55; // * height
  private float yesX = .375; // * width
  private float yesY = .55; // * height
  private int eraseScoresOpaqueness = 220;

  private Timer timer; 
  /* only instantiated to call methods which SHOULD BE STATIC, but processing
   treats all classes as inner classes wrapped in the main PApplet class, 
   and inner classes can't have static methods */

  // this keeps track of the index of most recently committed score
  private color mrcColor = color(255, 0, 0);
  // display most recently committed score for a given difficulty in different color
  private HashMap<String, Integer> mrcIndices;



  /*********** CONSTRUCTOR ACCEPTS GAME PARAMETERS ************/
  public Scores(int spc, String mode) {
    initializeGameVariables(spc, mode); // this must be called so that scores.length is defined!

    mrcIndices = new HashMap<String, Integer>();
    for (Integer i : Tap_It.spcNumbers) {
      mrcIndices.put(Tap_It.sdPath + "/Survivor" + "/" + Integer.toString(i) + ".txt", -1);
      mrcIndices.put(Tap_It.sdPath + "/TimeTrial" + "/" + Integer.toString(i) + ".txt", -1);
    }

    inErase = false;
    textSize = height / (scores.length / 2 + 2);
    eraseTextSize *= height;
    eraseX *= width;
    eraseY *= height;
    confirmTextSize *= height;
    noX *= width;
    noY *= height;
    yesX *= width;
    yesY *= height;
    
    column1x *= width;
    column2x *= width;

    timer = new Timer(0);
  }


  /*********** THIS BLANK CONSTRUCTOR TO BE USED ONLY AS AN INITIALIZER ************/
  public Scores() {   

    path = Tap_It.sdPath;
    String[] newScores = new String[NSCORES];
    for (int i = 0; i < newScores.length; i++)
      newScores[i] = BLANK;

    createDirectory(path + "/Survivor");
    createDirectory(path + "/TimeTrial");
    for (Integer i : Tap_It.spcNumbers) {
      createFile(path + "/Survivor" + "/" + Integer.toString(i) + ".txt", newScores);
      createFile(path + "/TimeTrial" + "/" + Integer.toString(i) + ".txt", newScores);
    }
  }



  /*********** set the path based on the input game parameters ************/
  private void buildPath(int spc, String mode) {
    path = new String();
    if (mode.equals(Tap_It.SURVIVOR))
      path = Tap_It.sdPath + "/Survivor" + "/" + spc + ".txt";
    if (mode.equals(Tap_It.TIME_TRIAL))
      path = Tap_It.sdPath + "/TimeTrial" + "/" + spc + ".txt";
  }

  /*********** initialize or change game varibles that Scores displays ************/
  public void initializeGameVariables(int spc, String mode) {
    this.mode = mode;
    this.spc = spc;
    buildPath(spc, mode);
    scores = loadStrings(path);
  }





  // display scores
  public void display() {
    // what to display in scores screen
    if (!inErase) {

      background(BG);
      fill(TEXTCOLOR);
      textAlign(CENTER, CENTER);
      textSize(textSize);

      // display score screen title
      text(spc + " : " + mode, width / 2, textSize);

      /* all scores, including times, are stored as integers in the score text files, 
       so display converts them to a human readable string 
       (for example, from an integer number of milliseconds to a string of minutes and seconds)
       before displaying them, depending on the mode */

      // 1st column of scores
      for (int i = 0; i < scores.length / 2; i++)
        text(scoreToDisplay(i), column1x, (i + 2) * textSize);

      // 2nd column of scores
      for (int i = scores.length / 2; i < scores.length; i++) 
        text(scoreToDisplay(i), column2x, (i + 2 - scores.length / 2) * textSize);

      // option to erase scores for this screen
      textSize(eraseTextSize);
      fill(mrcColor);
      text("Erase", eraseX, eraseY);
    }

    textAlign(LEFT, BASELINE); // return text alignment to default setting
  }

  // just called once to lay on top of scores screen so scores are dimly visible in background
  public void displayEraseScores() {

    rectMode(CORNER);
    fill(0, eraseScoresOpaqueness);
    rect(0, 0, width, height);

    textAlign(CENTER, CENTER);
    textSize(confirmTextSize);

    // display confirmation question
    fill(mrcColor);
    text("Erase all scores?", .5 * width, noY - 2.0 * confirmTextSize);
    fill(TEXTCOLOR);
    text("Yes", yesX, yesY);
    text("No", noX, noY);

    textAlign(LEFT, BASELINE); // return text alignment to default setting
  }



  // helper function that formats (colors) and returns score string to be displayed
  private String scoreToDisplay(int index) {
    String score = scores[index];

    int mrcIndex = (int) mrcIndices.get(path);
    if (index == mrcIndex)
      fill(mrcColor);
    else
      fill(TEXTCOLOR);


    if (score.equals(BLANK))
      return score; 

    if (mode.equals(Tap_It.SURVIVOR))
      return score;
    // text() accepts integer input, automatically parses it to a string

    if (mode.equals(Tap_It.TIME_TRIAL))
      return timer.timeToStringMinutes(Integer.parseInt(score));

    return new String(); // just in case
  }





  /* this method can be used to add a new score: 
   either an integer number of points for survivor mode, 
   or an integer number of milliseconds elapsed for time trial */
  public void addScore(int score, int spc, String mode) {
    buildPath(spc, mode);
    scores = loadStrings(path);

    int mrcIndex = -1;
    for (int i = 0; i < scores.length; i++) {

      if (scores[i].equals(BLANK)) {
        // check this first, to make sure parseInt isn't called on an unparsable input
        mrcIndex = i;  
        break;
      }

      if (mode.equals(Tap_It.SURVIVOR) && score > Integer.parseInt(scores[i])) {
        // score in text file must be converted to an integer to allow comparison
        mrcIndex = i;
        break;
      }

      if (mode.equals(Tap_It.TIME_TRIAL) && score < Integer.parseInt(scores[i])) {
        // in time trial smaller score (time) is better, in survivor bigger score (cards) is better
        mrcIndex = i;
        break;
      }
    }

    mrcIndices.put(path, mrcIndex);

    if (mrcIndex == -1)
      return; // new score wasn't higher than any of the scores on the high score list


    // if score was high enough, move all scores down one notch until you get to appropriate position
    for (int i = scores.length - 1; i > mrcIndex; i--) 
      scores[i] = scores[i - 1];

    // insert new high score into appropriate position
    scores[mrcIndex] = Integer.toString(score);


    /* write new scores to the text file after they've been updated.
     a fatal problem could occur if the program crashed while these strings
     were being written to the text file. to make this bulletproof i need a function
     in this class that checks all the high scores files in setup in the main 
     program and makes sure they exist and are properly formatted */
    saveStrings(path, scores);
  } 



  // allow main class to move scores screen between erase confirmation scores screen
  public void setErase(boolean inErase) {
    this.inErase = inErase;
  }

  /* if !inErase, return 0 for back click, 1 for erase. if inErase,
   return 2 for no click, 3 for yes
   */
  public int checkClick() {
    if (!inErase) {
      if (dist(mouseX, mouseY, eraseX, eraseY) < eraseTextSize * 1.25)
        return 1;
      return 0;
    } 
    else {
      if (dist(mouseX, mouseY, noX, noY) < eraseTextSize * 1.25)
        return 2;
      if (dist(mouseX, mouseY, yesX, yesY) < eraseTextSize * 1.25)
        return 3;
    }
    return -1; // nothing was clicked
  }

  public void eraseScores() {
    buildPath(spc, mode);

    String[] newScores = new String[NSCORES];
    for (int i = 0; i < newScores.length; i++)
      newScores[i] = BLANK;

    overwriteFile(path, newScores);
    scores = loadStrings(path);
    mrcIndices.put(path, -1); // most recently committed score for this mode no longer exists
  }






  /* for building directories and files in which data is stored, calling this function will only do
   something the first time the app is run, or if for some reason the data directory is deleted
   from the sd card of the user's phone. the following line is in the manifest file:
   
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
   
   this gives the app permission to write to the sd card. i would rather write to the data folder,
   i.e. internal storage inside the app which is not visible to the rest of the apps on the phone,
   but processing has no way of doing this. you can read from the data directory but you can't
   write to it...
   */
  void createDirectory(String directory) {
    try {
      File file = new File(directory);
      if (!file.exists()) {
        file.mkdirs();
        println("directory created : " + directory);
      }
    }
    catch(Exception e) { 
      e.printStackTrace();
    }
  }

  void createFile(String fileName, String[] lines) {
    try {
      File file = new File(fileName);
      if (!file.exists()) {
        saveStrings(fileName, lines);
        println("file created : " + fileName);
      }
    }
    catch(Exception e) { 
      e.printStackTrace();
    }
  }

  void overwriteFile(String fileName, String[] lines) {
    try {
      saveStrings(fileName, lines);
      println("file overwritten : " + fileName);
    }
    catch(Exception e) { 
      e.printStackTrace();
    }
  }
}

