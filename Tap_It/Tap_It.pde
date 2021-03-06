import java.util.Stack;
import java.util.Collections;
import apwidgets.*; // for APMediaPlayer

import android.os.Environment;
import java.io.*;
/****************************************/

private static final String DISPLAY_NAME = "Tap  It";
private static final String APPNAME = "TapIt";
private static String sdPath = null;


private static final int spcInitialIndex = 1;
private static Integer[] spcNumbers = { 
  3, 4, 5, 6, 8, 9, 10
}; 

public static String SURVIVOR = "Survivor"; // static constants for modes of play
public static String TIME_TRIAL = "Time trial";
private static final int modeInitialIndex = 0;
private static String[] modes = {
  TIME_TRIAL, SURVIVOR
};


private static int spc; // default spc. symbols per card, 3 - 10 is allowed, with the exception of 7
private static String mode;

private static int nSyms; // number of cards in deck, also number of unique symbols in deck

private static PImage[] allImgs;
private static String[] deckInfo;
private static final int nImages = 100;


private Deck deck;
private ArrayList<Card> cards;
private float dx = .71; // deck position, * width
private float dy = .48; // * height

private Player p1;
private float px = .235; // player position, * width
private float py = .48; // * height
private PFont font; // THIS IS THE ONLY FONT IN THE ENTIRE APPLICATION, IT DOESN'T CHANGE
private static final float cardRadius = .22; // * width, multiplication done in subclass constructors


private Splash splash; // this class manages the flow of the game, read more in its documentation
private Scores scores;
private boolean commitToScores;
private int scoreToCommit;
private int spcToCommit;
private String modeToCommit;
private Wait wait;
private final int WAIT_TIME = 1000; // milliseconds of wait time before game starts
private Intro intro; // this is displayed at first and then uninstantiated


private static int extraPerCard; // increment player's time limit by this amount each time he gets a match
private final int msPerSymbol = 3000; // allot this initial time for a player in survivor mode
private final int extraPerCardPerSymbol = 500;
private static final float extraTimeDecayOrder = .7; // 1 is reciprocal decay as score increases, 2 is quadratic decay, etc
private static int timeLimit;
private static final int PENALTY = 1000; // 1000 ms = 1 second, time penalty for an incorrect card


private static APMediaPlayer mPlayer; // for sound playback, must be released when the sketch is destroyed
private static final String START = "sounds/start.ogg"; // relative paths to sound files passed to mPlayer
private static final String CORRECT = "sounds/correct.ogg";
private static final String WRONG = "sounds/wrong.ogg";

/******************************************
 * Processing or java on my computer has a bug and requires the absolute path to load data,
 * when running on Android the path relative to the sketch folder must be used
 *******************************************/
//private static String path = "/Users/kylebebak/Desktop/Dropbox/Programming/Processing/XX__WebAndMobileApps/Projects/Match it/Tap_It/data/";
private static String path = new String();



void setup() {

  size(displayWidth, displayHeight); 
  orientation(LANDSCAPE);
  smooth();

  dx *= width; // deck and player positions
  dy *= height;
  px *= width;
  py *= height;
  /********** STRANGE BUGS OCCUR WHEN multiplying variables by width and height in setup, be careful **********/

  /***************************************
   * Import and parse symbol images
   ****************************************/
  allImgs = new PImage[nImages];
  for (int i = 0; i < nImages; i++)
    allImgs[i] = loadImage(path + "images/img" + Integer.toString(i) + ".png");

  font = loadFont(path + "Chalkboard-80.vlw");
  textFont(font); // this sets the text font for the entire application, it is never changed

  /***************************************
   * Initialize media player to play sounds
   ****************************************/
  mPlayer = new APMediaPlayer(this); // create new APMediaPlayer
  mPlayer.setLooping(false); // don't restart when end of playback has been reached
  mPlayer.setVolume(1.0, 1.0); // max left and right volumes, range is from 0.0 to 1.0


  /***************************************
   * Create directories and files for scores if they don't exist
   ****************************************/
  sdPath = Environment.getExternalStorageDirectory().getAbsolutePath();
  sdPath = sdPath + "/" + APPNAME;


  /***************************************s
   * Initialize game screens, games goes intro on setup
   ****************************************/
  splash = new Splash();
  // command center for the game, menu screen

  Scores scoresInitializer = new Scores(); 
  /* no-argument constructor creates directories and files if they're not currently on phone.
   sdPath MUST BE INITIALIZED before calling any of the scores constructors */

  scores = new Scores(6, TIME_TRIAL);
  commitToScores = false;
  // initialize global scores to default game values, this has to be instantiated for addScore to be called

  intro = new Intro();
  // initialize intro screen
}





// called each time a new game starts, ensures a random sampling of the available images is used for each game
void initializeGame() {

  shuffleArray(allImgs); // ensures that a random sampling of the available images are chosen for the deck

  /***************************************
   * Set game variables to values supplied by Sliders in Splash
   ****************************************/
  spc = splash.spc();
  mode = splash.mode();
  extraPerCard = round(extraPerCardPerSymbol * spc); // only matters for SURVIVOR mode
  timeLimit = round(msPerSymbol * spc);

  /***************************************
   * Import and parse deck info based on spc (symbols per card)
   ****************************************/
  deckInfo = loadStrings(path + "text/spc_" + Integer.toString(spc) + ".txt");
  nSyms = Integer.parseInt(deckInfo[0]);


  /***************************************
   * Instantiate cards and add them to cards ArrayList
   ****************************************/
  cards = new ArrayList<Card>();
  int[] cardIndices;
  String[] symbols;

  for (int c = 1; c <= nSyms; c++) {
    cardIndices = new int[spc];
    symbols = deckInfo[c].split(" ");

    for (int j = 0; j < spc; j++)
      cardIndices[j] = Integer.parseInt(symbols[j]);

    cards.add(new Card(spc, cardIndices, 0, 0));
    // it doesn't matter what the location of the added cards is
    // because addCard() changes the position of the card to the
    // current deck position
  }


  /***************************************
   * Instantiate deck, shuffle cards ArrayList, add cards to deck
   ****************************************/
  deck = new Deck(dx, dy);
  Collections.shuffle(cards);
  for (Card c : cards)
    deck.addCard(c);


  /***************************************
   * Instantiate players with a card each from the top of the deck
   ****************************************/
  p1 = new Player(px, py, deck.removeTop(), deck, timeLimit);


  /***************************************
   * Play start sound
   ****************************************/
  mPlayer.setMediaFile(START); // pass a String with relative path to start.ogg
  mPlayer.start(); // start playback
}


// go to wait screen before game is initialized
void initializeWait() {
  wait = new Wait(WAIT_TIME);
}


// go to score screen specified by current slider values
void initializeScores() {
  scores.initializeGameVariables(spc, mode);
}





void draw() {

  /***************************************
   * Commit any pending scores to scores
   ****************************************/
  if (commitToScores) {
    scores.addScore(scoreToCommit, spcToCommit, modeToCommit);
    commitToScores = false;
  }

  /***************************************
   * What to draw and do if game HAS NOT YET STARTED
   ****************************************/
  if (intro != null) {
    intro.display();
    return;
  }

  /***************************************
   * What to draw and do if game state is splash screen
   ****************************************/
  if (!splash.inPlay() && !splash.inScores() && !splash.inWait()) {
    splash.displayAndUpdate();

    spc = splash.spc();
    mode = splash.mode();
  }


  /***************************************
   * What to draw and do if game is in wait screen
   ****************************************/
  if (splash.inWait()) {

    if (wait != null) {
      wait.displayAndUpdate();
      if (wait.timeIsUp()) {
        wait = null;
        initializeGame();
        splash.setWaitStatus(false);
        splash.setGameStatus(true);
      }
      return;
    }
  }

  /***************************************
   * What to draw and do if game is in play
   ****************************************/
  if (splash.inPlay()) {
    p1.displayAndUpdate(); // player is responsible for displaying everything in the game

      if (deck.getSize() == 0) {

      if (mode.equals(TIME_TRIAL)) {
        int timeElapsed = p1.timeElapsed();
        p1.fixAndDisplayTime(timeElapsed);
        commitToScores(timeElapsed, spc, mode);
        // ensure same time is committed to scores as is displayed on the screen
        restartSplash();
      }

      // if in survivor mode, deck must be recycled without reinstantiating player
      if (mode.equals(SURVIVOR)) {
        deck = new Deck(dx, dy);
        Collections.shuffle(cards);
        for (Card c : cards)
          if (c != p1.getCard()) // check reference equality, add all cards to deck except player's current card
              deck.addCard(c);

        p1.giveDeck(deck);
        mPlayer.setMediaFile(START); // play start sound in survivor mode every time player goes through deck
        mPlayer.start();
      }
    }


    if (p1.timeIsUp() && mode.equals(SURVIVOR)) {
      // time running out only matters in SURVIVOR mode
      commitToScores(p1.getScore(), spc, mode); // the number of cards the player got before time ran out 
      restartSplash();
    }
  }


  /***************************************
   * What to draw and do if scores state is active
   ****************************************/
  if (splash.inScores()) {
    scores.display();
  }
}



// helper function takes game back to splash screen so it can be restarted
void restartSplash() {
  if (splash.inPlay()) {
    loadPixels(); // this must be called before get() because of a bug in android processing
    splash.setBackground(get()); // set the splash page background to be current game screen
    updatePixels();
  }

  splash.setWaitStatus(false);
  splash.setGameStatus(false);
  splash.setScoresStatus(false);
}




// implementing interaction, all of it is done with screen presses and drags
void mousePressed() {

  /******** Don't register other mouse events until intro screen is finished *********/
  if (intro != null) {
    if (intro.checkClick())
      intro = null;
    return;
  }


  /******** Checking in game *********/
  if (splash.inPlay()) {
    if (p1.checkBack()) {
      if (mode.equals(SURVIVOR))
        commitToScores(p1.getScore(), spc, mode); // commit score on back click for survivor mode
      restartSplash();
      return;
    }
    p1.checkClick();
  }


  /******** Checking in scores *********/
  if (splash.inScores()) {
    int scoresClickedWhere = scores.checkClick();
    if (scoresClickedWhere == 0) {
      restartSplash();
      return;
    }

    if (scoresClickedWhere == 1) {
      scores.setErase(true);
      scores.displayEraseScores(); // this is called only once, not in draw loop
      return;
    }

    if (scoresClickedWhere == 2) {
      scores.setErase(false);
      return;
    }

    if (scoresClickedWhere == 3) {
      scores.eraseScores();
      scores.setErase(false);
      return;
    }
  }


  /******** Checking in splash *********/
  int splashClickedWhere = splash.checkClick(); // can only be called once per draw loop
  if (splashClickedWhere == 0) {
    initializeWait();
    return;
  }

  if (splashClickedWhere == 1) {
    initializeScores();
    return;
  }
}

void mouseDragged() {
  if (splash.inPlay())
    p1.checkRotate();
}

void mouseReleased() {
  if (splash.inPlay())
    p1.checkRelease();
}






// return a pointer to the image from the allImgs array specified by the input index
public static PImage imageAtIndex(int index) {
  return allImgs[index];
}


// return a pointer to the media player, so that other classes can call it
public static APMediaPlayer getPlayer() {
  return mPlayer;
}

/********************************************************************
 ********************************************************************
 ********************************************************************
 testing to see if this avoids a common crash issue i've been having,
 it simply makes sure that addScore is always called at the beginning
 of draw
 */
public void commitToScores(int score, int spc, String mode) {
  commitToScores = true; 
  scoreToCommit = score;
  spcToCommit = spc;
  modeToCommit = mode;
}


// implementing Fisher–Yates shuffle
void shuffleArray(PImage[] a)
{
  for (int i = a.length - 1; i >= 0; i--)
  {
    int index = (int) random(i + 1);
    // Simple swap
    PImage p = a[index];
    a[index] = a[i];
    a[i] = p;
  }
}

