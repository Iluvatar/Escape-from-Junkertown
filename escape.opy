settings {
    "main": {
        "description": "Escape from Junkertown!\nYour brilliant plan went wrong, and now you're trapped in Junkertown. Can you find the way out?\nCode: 4K66K\nv0.10 Made by EruIluvatar",
        "modeName": "Escape from Junkertown"
    },
    "lobby": {
        "team2Slots": 0
    },
    "gamemodes": {
        "escort": {
            "enabledMaps": [
                "junkertown"
            ],
            "enableHeroSwitching": false,
            "gamemodeStartTrigger": "immediately",
            "roleLimit": "2OfEachRolePerTeam",
            "payloadSpeed%": 500,
            "respawnTime%": 0,
            "spawnHealthPacks": "disabled"
        },
    },
    "heroes": {
        "allTeams": {
            "ashe": {
                "enableInfiniteUlt": true
            },
            "junkrat": {
                "enablePrimaryFire": false,
                "enableAbility1": false,
                "enableAbility2": false,
                "enableMelee": false,
                "enableUlt": false
            },
            "roadhog": {
                "enablePrimaryFire": false,
                "enableSecondaryFire": false,
                "enableAbility1": false,
                "enableAbility2": false,
                "enableMelee": false,
                "enableUlt": false
            },
        }
    }
}



#!extension beamEffects
#!extension beamSounds
#!extension buffAndDebuffSounds
#!extension explosionSounds
#!extension kineticExplosionEffects
#!extension playMoreEffects

#!define PI 3.1415926535
#!define INF 100000000
#!define RACE_CONDITION_DELAY 0.1



enum Item:
    ID = 0, # unique item id (descriptive string)
    STATE, # state of the item (int)
    POINT, # location of the item (vect)
    RADIUS, # radius for item interaction (float)
    MESSAGE, # messages for item based on state (string array)
    ITEM_NAME, # name of received item if interacted with (string)
    PLAY_GET_SOUND, # whether to play interaction sound (bool)
    NEEDS_LOS, # whether los is needed to interact (bool)
    REMOVE_ON_STATE, # state at which the point is removed (int)
    # item use points use the fields below
    REQUIRED_ITEM, # item required to use with this point based on state (string array, matches with ITEM_NAME)
    SUCCESS_MESSAGE # message to play on successful item use based on state (string array)

# GLOBAL SETTINGS

#!define INTERACT_DISTANCE 4
#!define WALL_MESSAGE_TIMEOUT 3
#!define WALL_CHECK_TIME (0.016 * 4)
#!define TUTORIAL_GATE_OPEN_TIME 2
#!define TUTORIAL_GATE_OFFSET 0.52
#!define POWER_OFF_COLOR Color.RED
#!define POWER_BROKEN_COLOR Color.BLACK
#!define ALCOHOL_COST 60
#!define SMUGGLER_COST 100

#!define MOLE_PERSON_DEVICE_NAME "Anathema Device"

#!define BARN_NPC_HIDE_LOCATION vect(51, 9.15, -57)
#!define BRUCE_TEXT_LOCATION vect(-21.62, 6.48 + 1.6, -104.95)
#!define INSIDE_SMUGGLER_TEXT_LOCATION vect(-19.06, 13.48 + 1.6, -88.07)
#!define OUTSIDE_SMUGGLER_TEXT_LOCATION vect(-44.52, 4.49 + 1.6, -49.63)
#!define BARTENDER_TEXT_LOCATION vect(-54.65, 1.73 + 1.8, -131.02)
#!define NOT_SMUGGLER_TEXT_LOCATION vect(-35.02, 1.48 + 1.6, -126.33)

#!define DOOR_21_TEXT_LOCATION vect(-50.47, 13.63 + 0.6, -84.74)
#!define DOOR_22_TEXT_LOCATION vect(-54.41, 13.63 + 0.6, -84.09)
#!define DOOR_23_TEXT_LOCATION vect(-59.72, 13.63 + 0.6, -85.31)
#!define DOOR_24_TEXT_LOCATION vect(-48.46, 13.63 + 0.6, -90.79)
#!define DOOR_25_TEXT_LOCATION vect(-42.10, 14.63 + 0.6, -94.75)

#!define MOLE_PERSON_ROOM_TEXT_LOCATION vect(-51.97, 6.14 + 0.6, -3.03)
#!define MOLE_PERSON_OUTHOUSE_TEXT_LOCATION vect(31.32, 10.46, -48.16)
#!define MOLE_PERSON_CAR_TEXT_LOCATION vect(-12.12, 6.35, -33.15)
#!define MOLE_PERSON_CLIFF_TEXT_LOCATION vect(-2.96, 8.95, -100.44)

#!define OUTER_MINIGAME_BALL_SIZE 0.05



# GLOBAL VARIABLES

globalvar skipCutscenePlayers = []
globalvar introStage1Players = []
globalvar introStage2Players = []
globalvar tutorialPlayers = []
globalvar graphicsQualityPlayers = []
globalvar playersInDark = []
globalvar innerWirePlayers = []
globalvar powerPanelPlayers = [[], [], [], [], []]
globalvar innerMinigamePlayers = []
globalvar radioSmokePlayers = []
globalvar outerMinigamePlayers = []
globalvar barnHintPlayers = []
globalvar mapMarkerPlayers = []
globalvar barnMinigamePlayers = []
globalvar dvdLogoPlayers = []
globalvar satControlPlayers = []
globalvar insideMailTextPlayers = []
globalvar outsideMailTextPlayers = []

# tutorial text
enum TutorialText:
    INTERACT,
    INV_CYCLE,
    APPLY_ITEM,
    HINTS

globalvar tutorialTextPlayers = [[], [], [], [], []]

# equippables
enum Equip:
    HAS_ANY = 0,
    LITTLE_BUDDY,
    SUNSCREEN,
    SUNGLASES,
    DISGUISE,
    WINGS

globalvar equipPlayers = [[], [], [], [], []]

# achievements
enum Achievement:
    HAS_ANY = 0,
    MOST_WANTED, # find all the posters
    INFRASIGHT, # find the sunglasses without using the map
    PUZZLE_MASTER, # finish the color minigame in 5 moves
    IN_A_HURRY, # click on Bruce 60 times before the minute is up
    MASTER_HACKER, # look through the binoculars
    ESCAPE_ARTIST, # escape Junkertown
    END_MARKER # always at the end, the number of total achievements

# cutscenes
enum Cutscene:
    NONE = 0,
    INTRO,
    WAKING,
    INNER_RADIO,
    COMEDY,
    BRUCE_CONTACT,
    MOLE_LEADER_INTERACTION,
    MOLE_AGENT_INTERACTION,
    ENDING

# interaction point ids
enum Id:
    # item apply points
    tutGate1,
    tutGate2,
    innerWires,
    innerBarrel2,
    innerGenerator,
    innerRadio,
    innerWorkbench,
    innerToolbox2,
    outerWorkbench,
    outerBruce,
    outerSmuggler,
    outerBartender,
    outerNotSmuggler,
    outerDoor21,
    outerDoor22,
    outerDoor23,
    outerDoor24,
    outerDoor25,
    barnWorkbench,
    outsideHose,
    outsideSatControl,
    outsideSmuggler,
    outsideMolePersonRoom,
    outsideMolePersonOuthouse,
    outsideMolePersonCar,
    outsideMolePersonCliff,

    # interaction points
    # tutorial room
    tutSafe1,
    tutSafe2,
    tutSafe3,
    tutSafe4,
    tutSafe5,
    tutGold,
    tutBarrel1,
    tutBarrel2,
    tutBarrel3,
    tutBarrel4,
    tutBarrel5,
    tutBarrel6,
    tutBarrel7,
    # lights on section
    innerFridge,
    innerChest1,
    innerLocker1,
    innerLocker2,
    innerLocker3,
    innerLocker4,
    innerLocker5,
    innerPowerDistributor,
    innerBarrel1,
    innerBarrel3,
    innerNotBarrel,
    innerSwitch1,
    innerSwitch2,
    innerSwitch3,
    innerSwitch4,
    innerSwitch5,
    innerPowerBox,
    # larger inner section
    innerThrone,
    innerChest2,
    innerToolbox1,
    innerSmallToolbox1,
    innerTireRack,
    innerBrokenMech1,
    innerBrokenMech2,
    innerMech1,
    innerMech2,
    innerMinigameControl1,
    innerMinigameControl2,
    innerMinigameSkip,
    innerSunglasses,
    innerValve1,
    innerValve2,
    innerValve3,
    innerVent1,
    innerVent2,
    innerVent3,
    innerVent4,
    innerVent5,
    innerVent6,
    innerVent7,
    # courtyard area
    outerIceBox,
    outerSmallToolbox1,
    outerToolbox1,
    outerToolbox2,
    outerToolbox3,
    outerRadio,
    outerMic,
    outerWaterBarrel,
    outerCart,
    outerPoster1,
    outerPoster2,
    outerPoster3,
    outerPoster4,
    outerPoster5,
    outerPoster6,
    outerPoster7,
    outerPoster8,
    outerPoster9,
    outerPoster10,
    outerPosterOob11,
    outerPosterOob12,
    outerPosterOob13,
    outerPosterOob14,
    outerPosterOob15,
    outerBinoculars,
    outerMinigameDot1,
    outerMinigameDot2,
    outerMinigameDot3,
    outerMinigameDot4,
    outerMinigameDot5,
    outerMinigameDot6,
    outerMinigameDot7,
    outerMinigameDot8,
    outerMinigameDot9,
    outerMinigameDot10,
    outerMinigameRotate1,
    outerMinigameRotate2,
    outerMinigameRotate3,
    outerMinigameSkip,
    # barn area
    barnRadio,
    barnTvPanel,
    barnPachimari,
    barnFuelMachine,
    barnFridge,
    barnTireRack,
    barnPlan,
    barnToolbox1,
    barnToolbox2,
    barnSmallToolbox1,
    barnSafe1,
    barnSafe2,
    barnSafe3,
    barnEmptyShelf,
    barnPaperClue1,
    barnPaperClue2,
    barnBike,
    barnSwitch1,
    barnSwitch2,
    barnSwitch3,
    barnSwitch4,
    barnSwitch5,
    barnCodePanel,
    barnMinigameDot0,
    barnMinigameDot1,
    barnMinigameDot2,
    barnMinigameDot3,
    barnMinigameDot4,
    barnMinigameDot5,
    barnMinigameDot6,
    barnMinigameDot7,
    barnMinigameDot8,
    barnMinigameSkip,
    # larger outside area
    outsideJunkWorkbench,
    outsideSafe,
    outsideIceBox,
    outsideFridge1,
    outsideFridge2,
    outsideFridge3,
    outsideFridge4,
    outsideToolbox1,
    outsideToolbox2,
    outsideSmallToolbox,
    outsideChest1,
    outsideChest2,
    outsideChest3,
    outsideChest4,
    outsideChest5,
    outsidePoster1,
    outsidePoster2

globalvar achievementPlayers = [[], [], [], [], [], [], []]

# NPCs

globalvar cartNpc
globalvar bruceNpc
globalvar outsideSmugglerNpc
globalvar insideSmugglerNpc
globalvar bartenderNpc
globalvar barnNpc

# other
globalvar outerMinigameColors = [Color.RED, Color.BLACK]
globalvar moleCoinRiddle = [
    "Retrieve the gold device...",
    "from where we cannot go...",
    "the horde of golden ice...",
    "then secrets we'll bestow."
]

globalvar moleLeaderRiddle = [
    "You hold the treasure in your hand...",
    "from where we cannot go...",
    "Now show it to our leader and...",
    "prepare the rest to know.", # change

    # "The door to seek is one of these",
    # "but not the first or last", "and ends with digit odd", "but sums to more than four", "but digits don't repeat",
    # "the digits don't repeat themselves", "it's neither square nor triangle shaped",
    # "and has no place to wipe your feet", "and has no mat upon the floor"
    "The door to seek is one of these...",
    "but digits don't repeat...",
    "it's neither square nor triangle shaped...",
    "and has no place to wipe your feet."
]

# PLAYER VARIABLES

playervar effectDeleteQueue = []
playervar textDeleteQueue = []

# General temp variables
playervar tIndex
playervar tValue
playervar tStart
playervar tEnd
playervar tPos
playervar tText
playervar tMinigame

# Player state
playervar pauseInteraction
playervar junkPos
playervar junkFacing
playervar hogPos
playervar hogFacing
playervar isJunk
playervar isHog
playervar junkInventory
playervar hogInventory
playervar inventory
playervar inventoryPlayer
playervar junkEquipped
playervar hogEquipped
playervar equipped
playervar insideSmugglerItem
playervar outsideSmugglerItem
playervar money
playervar achievements

# Game state
playervar tutorialFinished
playervar wiresConnected
playervar generatorOn
playervar powerSwitched
playervar lightsOn

playervar isDoingInnerMinigame
playervar isHoldingInnerMinigameControl1
playervar isHoldingInnerMinigameControl2
playervar innerMinigameValue1
playervar innerMinigameValue2
playervar hasFinishedInnerMinigame

playervar hasFoundInnerRadio
playervar canBeTheOtherGuy

playervar numVentsClosed
playervar hasSunglasses
playervar hasSunscreen
playervar canGoOutside

playervar barnCode
playervar barnCodeInputted
playervar canLeaveBarn
playervar canAccessBarnSecret

playervar isDoingOuterMinigame
playervar outerMinigameState
playervar hasFinishedOuterMinigame

playervar canUtilizeSmuggler

playervar isDoingBarnMinigame
playervar barnMinigameColorState
playervar barnMinigamePosState
playervar hasFinishedBarnMinigame

playervar molePersonRiddleLine
playervar molePersonInteractStage

playervar bruceTimer

playervar hasFinishedGame
playervar isOnSecondRun = false

playervar isDoingHint
playervar hintText

# achievements
playervar postersFound
playervar outsideMapFound
playervar outerMinigameMovesMade
playervar timesBruceClicked

# Item points

playervar itemPoints
playervar itemIds

# Item apply points

playervar tutGate1
playervar tutGate2

playervar innerWires
playervar innerBarrel2
playervar innerGenerator
playervar innerRadio
playervar innerWorkbench
playervar innerToolbox2

playervar outerBruce
playervar outerSmuggler
playervar outerBartender
playervar outerNotSmuggler
playervar outerWorkbench
playervar outerDoor21
playervar outerDoor22
playervar outerDoor23
playervar outerDoor24
playervar outerDoor25

playervar barnWorkbench

playervar outsideHose
playervar outsideSatControl
playervar outsideSmuggler
playervar outsideMolePersonRoom
playervar outsideMolePersonOuthouse
playervar outsideMolePersonCar
playervar outsideMolePersonCliff

# Other
playervar tutorialGate1End
playervar tutorialGate2End

playervar skipAlpha
playervar currentCutscene
playervar isCutsceneFinished

playervar bezier
playervar bezierDuration



# UTILITIES

# 2d arrays can't be modified directly, so we have to pull out a row, modify it, then reinsert it

# get an item entry by id
#!define GET_ITEM_ENTRY(id) [elem for elem in eventPlayer.itemPoints if elem[Item.ID] == id][0]

# save an item entry
#!define SAVE_STATE(item) eventPlayer.tIndex = eventPlayer.itemIds.index(item[Item.ID]) \
eventPlayer.itemPoints[eventPlayer.tIndex] = item

# distance between two vectors ignoring the height component
#!define DIST_2D(v1, v2) distance(vect((v1).x, 0, (v1).z), vect((v2).x, 0, (v2).z))

# distance from pos to the vertical plane defined by start and end vectors
#!define DIST_TO_WALL(start, end, pos) dotProduct(normalize(vect(-((end) - (start)).z, 0, ((end) - (start)).x)), pos - start)

# MAKE_WALL creates a vertical wall from start to end, pushing 90 degrees clockwise to the (end - start) vector
# when hit, displays the message, but with a timeout of WALL_MESSAGE_TIMEOUT
# it's an instantaneous check, so must be rerun every tick
playervar isShowingWallMessage = false

def doWallMessageTimeout():
    eventPlayer.isShowingWallMessage = true
    wait(WALL_MESSAGE_TIMEOUT)
    eventPlayer.isShowingWallMessage = false

#!define MAKE_WALL(start, end, message) if DIST_2D(((start) + (end)) / 2, eventPlayer.getPosition()) < distance(start, end) / 2 and eventPlayer.getPosition().y >= start.y and eventPlayer.getPosition().y <= end.y and DIST_TO_WALL(start, end, eventPlayer.getPosition()) < 0.9: \
    eventPlayer.setMoveSpeed(0) \
    eventPlayer.teleport(eventPlayer.getPosition() + normalize(vect(-((end) - (start)).z, 0, ((end) - (start)).x)) * (1 - DIST_TO_WALL(start, end, eventPlayer.getPosition()))) \
    if eventPlayer.isShowingWallMessage == false: \
        smallMessage(eventPlayer, message) \
        async(doWallMessageTimeout(), AsyncBehavior.NOOP) \
    eventPlayer.setMoveSpeed(100)

#!define MAKE_DAMAGE_WALL(start, end, message) if DIST_2D(((start) + (end)) / 2, eventPlayer.getPosition()) < distance(start, end) / 2 and eventPlayer.getPosition().y >= start.y and eventPlayer.getPosition().y <= end.y and DIST_TO_WALL(start, end, eventPlayer.getPosition()) < 1: \
    eventPlayer.clearStatusEffect(Status.INVINCIBLE) \
    damage(eventPlayer, eventPlayer, 50) \
    eventPlayer.setMoveSpeed(5) \
    eventPlayer.applyImpulse(vect(-((end) - (start)).z, 3, ((end) - (start)).x), 6, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION) \
    wait(0.1) \
    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INF) \
    eventPlayer.setHealth(200) \
    eventPlayer.setMoveSpeed(100)

# Push and pop effects using the effect deletion queue
def pushEffectDeleteQueue():
    eventPlayer.effectDeleteQueue.append(getLastCreatedEntity())

def popEffectDeleteQueue():
    destroyEffect(eventPlayer.effectDeleteQueue[0])
    del eventPlayer.effectDeleteQueue[0]

def popAllEffectDeleteQueue():
    while len(eventPlayer.effectDeleteQueue) > 0:
        popEffectDeleteQueue()

# Push and pop text using the text deletion queue
def pushTextDeleteQueue():
    eventPlayer.textDeleteQueue.append(getLastCreatedText())

def popTextDeleteQueue():
    destroyInWorldText(eventPlayer.textDeleteQueue[0])
    del eventPlayer.textDeleteQueue[0]

def popAllTextDeleteQueue():
    while len(eventPlayer.textDeleteQueue) > 0:
        popTextDeleteQueue()

# Creates in world text for the event player
#!define CREATE_COLORED_TEXT(text, location, color) popTextDeleteQueue() \
createInWorldText(eventPlayer, text, location, 1, Clip.NONE, WorldTextReeval.NONE, color, SpecVisibility.NEVER) \
pushTextDeleteQueue()

#!define CREATE_TEXT(text, location) CREATE_COLORED_TEXT(text, location, Color.WHITE)

# Moves playervars X, Y, and Z along the bezier defined by bezier[0:4] for the duration in bezierDuration
def doBezier():
    eventPlayer.A = eventPlayer.bezier[0]
    eventPlayer.B = eventPlayer.bezier[1]
    eventPlayer.C = eventPlayer.bezier[2]
    eventPlayer.D = eventPlayer.bezier[3]

    eventPlayer.X = eventPlayer.A
    eventPlayer.Y = eventPlayer.B
    eventPlayer.Z = eventPlayer.C
    eventPlayer.T = 0

    chase(eventPlayer.X, eventPlayer.B, duration=eventPlayer.bezierDuration, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.Y, eventPlayer.C, duration=eventPlayer.bezierDuration, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.Z, eventPlayer.D, duration=eventPlayer.bezierDuration, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.T, 1, duration=eventPlayer.bezierDuration, ChaseReeval.DESTINATION_AND_DURATION)

# Does bezier for all entries in eventPlayer.bezier
# is destructive for eventPlayer.bezier
def doBezierArray():
    while len(eventPlayer.bezier) >= 4:
        doBezier()
        wait(eventPlayer.bezierDuration, Wait.ABORT_WHEN_FALSE)
        del eventPlayer.bezier[0]
        del eventPlayer.bezier[0]
        del eventPlayer.bezier[0]

#!define BEZIER_POSITION ((eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T) + ((eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T) - (eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T)) * eventPlayer.T)
#!define BEZIER_FACING (eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T)

# Gives the player an item
#!define GIVE_ITEM(item) eventPlayer.inventory = item.concat(eventPlayer.inventory)

# Used to turn the whole screen black (doesn't actually fade)
#!define BLACK_SCREEN_POS vect(34, 6, -88)
#!define BLACK_SCREEN_FACING vect(0.01, -1, 0)
#!define FADE_TO_BLACK() eventPlayer.startCamera(BLACK_SCREEN_POS, BLACK_SCREEN_POS + BLACK_SCREEN_FACING, 0)

# Create text while faded to black
#!define LINE_SPACING 0.08
#!define CREATE_BLACK_TEXT(text, line) createInWorldText(eventPlayer, text, BLACK_SCREEN_POS + 2 * BLACK_SCREEN_FACING - vect(LINE_SPACING * (line), 0, 0), 1, Clip.NONE, WorldTextReeval.NONE, Color.WHITE, SpecVisibility.NEVER) \
pushTextDeleteQueue()

# Create text while faded to black that reevaluates
#!define CREATE_BLACK_TEXT_REEVAL(text, line) createInWorldText(eventPlayer, text, BLACK_SCREEN_POS + 2 * BLACK_SCREEN_FACING - vect(LINE_SPACING * (line), 0, 0), 1, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.NEVER) \
pushTextDeleteQueue()

# Creates text that can be scrolled using eventPlayer.tPos
#!define CREATE_MOVABLE_TEXT(text, line, size, color) createInWorldText(eventPlayer, text, BLACK_SCREEN_POS + 2 * BLACK_SCREEN_FACING - vect(LINE_SPACING * (line) - eventPlayer.tPos, 0, 0), size, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, color, SpecVisibility.NEVER) \
pushTextDeleteQueue()

# Increments the state of the item with the given id
#!define INCREMENT_STATE(id) eventPlayer.tValue = GET_ITEM_ENTRY(id) \
eventPlayer.tValue[Item.STATE]++ \
SAVE_STATE(eventPlayer.tValue)

#!define ADD_TO_STATE(id, val) eventPlayer.tValue = GET_ITEM_ENTRY(id) \
eventPlayer.tValue[Item.STATE] += val \
SAVE_STATE(eventPlayer.tValue)

# Sets the state of the item with the given id
#!define SET_STATE(id, value) eventPlayer.tValue = GET_ITEM_ENTRY(id) \
eventPlayer.tValue[Item.STATE] = value \
SAVE_STATE(eventPlayer.tValue)

def hideEquips():
    equipPlayers[Equip.HAS_ANY].remove(eventPlayer)
    equipPlayers[Equip.LITTLE_BUDDY].remove(eventPlayer)
    equipPlayers[Equip.SUNSCREEN].remove(eventPlayer)
    equipPlayers[Equip.SUNGLASES].remove(eventPlayer)
    equipPlayers[Equip.DISGUISE].remove(eventPlayer)
    equipPlayers[Equip.WINGS].remove(eventPlayer)

def manageEquips():
    hideEquips()

    if len(eventPlayer.equipped) > 0:
        equipPlayers[Equip.HAS_ANY].append(eventPlayer)
    if Equip.LITTLE_BUDDY in eventPlayer.equipped:
        equipPlayers[Equip.LITTLE_BUDDY].append(eventPlayer)
    if Equip.SUNSCREEN in eventPlayer.equipped:
        equipPlayers[Equip.SUNSCREEN].append(eventPlayer)
    if Equip.SUNGLASES in eventPlayer.equipped:
        equipPlayers[Equip.SUNGLASES].append(eventPlayer)
    if Equip.DISGUISE in eventPlayer.equipped:
        equipPlayers[Equip.DISGUISE].append(eventPlayer)
    if Equip.WINGS in eventPlayer.equipped:
        equipPlayers[Equip.WINGS].append(eventPlayer)

def hideAchievements():
    achievementPlayers[Achievement.HAS_ANY].remove(eventPlayer)
    achievementPlayers[Achievement.MOST_WANTED].remove(eventPlayer)
    achievementPlayers[Achievement.INFRASIGHT].remove(eventPlayer)
    achievementPlayers[Achievement.PUZZLE_MASTER].remove(eventPlayer)
    achievementPlayers[Achievement.IN_A_HURRY].remove(eventPlayer)
    achievementPlayers[Achievement.MASTER_HACKER].remove(eventPlayer)
    achievementPlayers[Achievement.ESCAPE_ARTIST].remove(eventPlayer)

def manageAchievements():
    hideAchievements()

    if len(eventPlayer.achievements) > 0:
        achievementPlayers[Achievement.HAS_ANY].append(eventPlayer)
    if Achievement.MOST_WANTED in eventPlayer.achievements:
        achievementPlayers[Achievement.MOST_WANTED].append(eventPlayer)
    if Achievement.INFRASIGHT in eventPlayer.achievements:
        achievementPlayers[Achievement.INFRASIGHT].append(eventPlayer)
    if Achievement.PUZZLE_MASTER in eventPlayer.achievements:
        achievementPlayers[Achievement.PUZZLE_MASTER].append(eventPlayer)
    if Achievement.IN_A_HURRY in eventPlayer.achievements:
        achievementPlayers[Achievement.IN_A_HURRY].append(eventPlayer)
    if Achievement.MASTER_HACKER in eventPlayer.achievements:
        achievementPlayers[Achievement.MASTER_HACKER].append(eventPlayer)
    if Achievement.ESCAPE_ARTIST in eventPlayer.achievements:
        achievementPlayers[Achievement.ESCAPE_ARTIST].append(eventPlayer)

def hideUi():
    eventPlayer.disableHeroHUD()
    hideEquips()
    hideAchievements()
    eventPlayer.inventoryPlayer.remove(eventPlayer)

def showUi():
    eventPlayer.enableHeroHud()
    manageEquips()
    manageAchievements()
    eventPlayer.inventoryPlayer.append(eventPlayer)

# Freezes and unfreezes the player
def freeze():
    eventPlayer.pauseInteraction = true
    eventPlayer.setStatusEffect(null, Status.ROOTED, INF)

def unfreeze():
    eventPlayer.pauseInteraction = false
    eventPlayer.clearStatusEffect(Status.ROOTED)

# Opens the barn secret area
def openSecretDoor():
    barnNpc.teleport(vect(54.41, 9.5, -64.48))
    wait(0.5)
    barnNpc.teleport(BARN_NPC_HIDE_LOCATION)
    # cooldown
    wait(5)

# Toggles visiblity of the given power panel switch
#!define TOGGLE_POWER_SWITCH(index) if eventPlayer in powerPanelPlayers[index]: \
    powerPanelPlayers[index].remove(eventPlayer) \
else: \
    powerPanelPlayers[index].append(eventPlayer)

# Checks if the player has activated all the power switches
def checkPowerPanel():
    if all([eventPlayer not in elem for elem in powerPanelPlayers]):
        eventPlayer.powerSwitched = true

# Converts between 2D and 3D coordinate locations for the inner workbench minigame
#!define INNER_MINIGAME_X_0 vect(-103.33, 0, -183.70)
#!define INNER_MINIGAME_X_MAX vect(-103.65, 0, -185.43)
#!define INNER_MINIGAME_Y_0 8.73
#!define INNER_MINIGAME_2D_TO_3D(vect2d) INNER_MINIGAME_X_0 + (INNER_MINIGAME_X_MAX - INNER_MINIGAME_X_0) * vect2d.x / distance(INNER_MINIGAME_X_0, INNER_MINIGAME_X_MAX) + vect(0, vect2d.y + INNER_MINIGAME_Y_0, 0)
#!define INNER_MINIGAME_3D_TO_2D(vect3d) vect(distance(INNER_MINIGAME_X_0, vect(vect3d.x, 0, vect3d.z)), vect3d.y - INNER_MINIGAME_Y_0, 0)

# Converts between 2D and 3D coordinate locations for the outer workbench minigame
#!define OUTER_MINIGAME_X_0 vect(-56.627, 0, -61.328)
#!define OUTER_MINIGAME_X_MAX vect(-56.286, 0, -59.735)
#!define OUTER_MINIGAME_Y_0 11.998
#!define OUTER_MINIGAME_2D_TO_3D(vect2d) OUTER_MINIGAME_X_0 + (OUTER_MINIGAME_X_MAX - OUTER_MINIGAME_X_0) * vect2d.x / distance(OUTER_MINIGAME_X_0, OUTER_MINIGAME_X_MAX) + vect(0, vect2d.y + OUTER_MINIGAME_Y_0, 0)
#!define OUTER_MINIGAME_3D_TO_2D(vect3d) vect(distance(OUTER_MINIGAME_X_0, vect(vect3d.x, 0, vect3d.z)), vect3d.y - OUTER_MINIGAME_Y_0, 0)

# Converts between 2D and 3D coordinate locations for the barn workbench minigame
#!define BARN_MINIGAME_X_0 vect(48.95, 0, -80.60)
#!define BARN_MINIGAME_X_MAX vect(48.77, 0, -82.33)
#!define BARN_MINIGAME_Y_0 10.22
#!define BARN_MINIGAME_3D_TO_2D(vect3d) vect(distance(BARN_MINIGAME_X_0, vect(vect3d.x, 0, vect3d.z)), vect3d.y - BARN_MINIGAME_Y_0, 0)

#!define BARN_X_VEC normalize(BARN_MINIGAME_X_MAX - BARN_MINIGAME_X_0)
#!define BARN_Z_VEC crossProduct(BARN_X_VEC, vect(0, -1, 0))
#!define BARN_A vect(BARN_X_VEC.x, 0, BARN_Z_VEC.x)
#!define BARN_C vect(BARN_X_VEC.z, 0, BARN_Z_VEC.z)
#!define BARN_MINIGAME_2D_TO_3D(v) BARN_MINIGAME_X_0 + vect(dotProduct(BARN_A, v), BARN_MINIGAME_Y_0 + v.y, dotProduct(BARN_C, v))

# Barn minigame values
globalvar barnMinigamePoints = [
    vect(0.85, 0.1, 0.055),
    vect(0.6, 0.8, 0.055),
    vect(0.55, 0.6, 0.055),
    vect(0.8, 0.3, 0.055),
    vect(0.75, 0.5, 0.055),
    vect(1.1, 0.8, 0.055),
    vect(1.15, 0.6, 0.055),
    vect(0.9, 0.3, 0.055),
    vect(0.95, 0.5, 0.055),
    vect(-1000, -1000, 0)
]

globalvar barnMinigameConnections = [
    [3, 7],
    [2, 8],
    [1, 3, 4],
    [0, 2],
    [2, 5, 8],
    [4, 6],
    [5, 7, 8],
    [0, 6],
    [1, 4, 6]
]

# Barn minigame click helper
# eventPlayer.tPos should be set to the dot index to process
# player variables tIndex and tMinigame are overwritten
def barnMinigameClick():
    # tPos: index (in state array) of the spot that was clicked
    # tIndex: index (in pos array) of the effect at the point that was clicked
    # tMinigame: index (in state array) of the open spot to move to
    # tStart: chase variable for moving dot
    # tEnd: moving dot effect id

    eventPlayer.tIndex = eventPlayer.barnMinigamePosState.index(eventPlayer.tPos)
    if eventPlayer.tIndex >= 0:
        eventPlayer.tMinigame = [e for e in barnMinigameConnections[eventPlayer.tPos] if eventPlayer.barnMinigameColorState[e] == 0]
        if len(eventPlayer.tMinigame) > 0:

            eventPlayer.tStart = barnMinigamePoints[eventPlayer.barnMinigamePosState[eventPlayer.tIndex]]
            createEffect(eventPlayer, Effect.SPHERE, Color.BLACK if eventPlayer.barnMinigameColorState[eventPlayer.tPos] == 1 else Color.BLUE, BARN_MINIGAME_2D_TO_3D(eventPlayer.tStart), 0.05, EffectReeval.POSITION_AND_RADIUS)
            eventPlayer.tEnd = getLastCreatedEntity()
            wait(RACE_CONDITION_DELAY)
            eventPlayer.barnMinigamePosState[eventPlayer.tIndex] = 9
            chase(eventPlayer.tStart, barnMinigamePoints[eventPlayer.tMinigame[0]], duration=0.3, ChaseReeval.NONE)
            wait(0.3)
            destroyEffect(eventPlayer.tEnd)
            stopChasingVariable(eventPlayer.tStart)

            eventPlayer.barnMinigamePosState[eventPlayer.tIndex] = eventPlayer.tMinigame[0]
            eventPlayer.barnMinigameColorState[eventPlayer.tMinigame[0]] = eventPlayer.barnMinigameColorState[eventPlayer.tPos]
            eventPlayer.barnMinigameColorState[eventPlayer.tPos] = 0
        else:
            playEffect(eventPlayer, DynamicEffect.EXPLOSION_SOUND, null, eventPlayer.getPosition(), 30)

# Converts between coords for the outside satellite control minigame
#!define OUTSIDE_SAT_CONTROL_ORIGIN vect(-4.106, 13.825, -83.328)
#!define OUTSIDE_SAT_TO_WORLD(pos) OUTSIDE_SAT_CONTROL_ORIGIN + vect(dotProduct(pos, vect(0.789, 0.120, -0.603)), dotProduct(pos, vect(-0.151, 0.989, 0)), dotProduct(pos, vect(-0.596, -0.091, -0.798)))

# Toggle outer minigame state
#!define OUTER_MINIGAME_TOGGLE(num) eventPlayer.outerMinigameState[num]++ \
eventPlayer.outerMinigameState[num] %= 2

# Enters a digit to the barn code
#!define ENTER_BARN_DIGIT(digit) eventPlayer.barnCodeInputted.append(digit) \
if len(eventPlayer.barnCodeInputted) > 5: \
    del eventPlayer.barnCodeInputted[0]

# Checks if the barn code has been inputted
def checkBarnCode():
    if eventPlayer.barnCodeInputted == eventPlayer.barnCode:
        eventPlayer.canAccessBarnSecret = true
        barnHintPlayers.remove(eventPlayer)

        # Ashe drop
        async(openSecretDoor(), AsyncBehavior.NOOP)

# Makes a noise for when a switch is pressed
def makeSwitchNoise():
    createEffect(eventPlayer, Effect.ECHO_FOCUSING_BEAM_SOUND, null, eventPlayer, 100, EffectReeval.NONE)
    pushEffectDeleteQueue()
    wait(0.3)
    popEffectDeleteQueue()

# Toggle the lights when a button is pressed on the barn code panel
# the y value should be set in eventPlayer.tPos
def toggleBarnSwitch():
    eventPlayer.tStart = []
    createEffect(eventPlayer.tStart, Effect.SPHERE, Color.RED, vect(56.656, eventPlayer.tPos, -66.630), 0.013, EffectReeval.VISIBILITY)
    pushEffectDeleteQueue()
    createEffect(eventPlayer.tStart, Effect.SPHERE, Color.RED, vect(56.647, eventPlayer.tPos, -66.629), 0.013, EffectReeval.VISIBILITY)
    pushEffectDeleteQueue()
    createEffect(eventPlayer.tStart, Effect.SPHERE, Color.RED, vect(56.639, eventPlayer.tPos, -66.628), 0.013, EffectReeval.VISIBILITY)
    pushEffectDeleteQueue()
    createEffect(eventPlayer.tStart, Effect.SPHERE, Color.RED, vect(56.630, eventPlayer.tPos, -66.6275), 0.013, EffectReeval.VISIBILITY)
    pushEffectDeleteQueue()
    createEffect(eventPlayer.tStart, Effect.SPHERE, Color.RED, vect(56.622, eventPlayer.tPos, -66.627), 0.013, EffectReeval.VISIBILITY)
    pushEffectDeleteQueue()
    createEffect(eventPlayer.tStart, Effect.SPHERE, Color.RED, vect(56.613, eventPlayer.tPos, -66.626), 0.013, EffectReeval.VISIBILITY)
    pushEffectDeleteQueue()

    eventPlayer.tStart.append(eventPlayer)

    createEffect(eventPlayer, Effect.ECHO_FOCUSING_BEAM_SOUND, null, eventPlayer, 100, EffectReeval.NONE)
    pushEffectDeleteQueue()
    wait(0.3)

    eventPlayer.tStart.remove(eventPlayer)

    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()



# SETUP

rule "Disable hero assemble":
    @Event global
    @Condition isAssemblingHeroes()

    setMatchTime(0)

rule "Disable setup":
    @Event global
    @Condition isInSetup()

    setMatchTime(0)

rule "Move payload to the end":
    @Event global
    @Condition isGameInProgress()

    # wait for starting player to get through intro so the sound doesn't interfere
    wait(15)

    createDummy(Hero.TRACER, Team.2, -1, vect(28.66, 10.54, -81.27), vect(-1, 0, 0))
    cartNpc = getLastCreatedEntity()
    cartNpc.startForcingName("Not a smuggler")
    cartNpc.setStatusEffect(null, Status.INVINCIBLE, INF)

rule "Stop payload after first point":
    @Event global
    @Condition getPayloadProgressPercentage() > 38.20

    pauseMatchTime()

    cartNpc.teleport(vect(-35.02, 1.48, -126.33))
    cartNpc.setFacing(vect(0.42, 0.10, -0.90), Relativity.TO_WORLD)

rule "Keep match time high to prevent time based voice lines":
    @Event global
    @Condition isGameInProgress()
    @Condition getMatchTime() < 3000

    setMatchTime(3600)

rule "Spawn NPCs":
    @Event global
    @Condition isGameInProgress()

    createDummy(Hero.ASHE, Team.2, -1, vect(-46, 14, -70), vect(-0.98, 0, -0.07))
    barnNpc = getLastCreatedEntity()
    wait(RACE_CONDITION_DELAY)
    barnNpc.setInvisibility(Invis.ALL)
    barnNpc.disablePlayerCollision()
    barnNpc.setUltCharge(100)
    # barnNpc.forceButtonPress(Button.ULTIMATE)
    barnNpc.teleport(BARN_NPC_HIDE_LOCATION)

    createDummy(Hero.TORBJORN, Team.2, -1, vect(-21.62, 6.48, -104.95), vect(0.92, 0, 0.39))
    bruceNpc = getLastCreatedEntity()
    bruceNpc.startForcingName("Bruce")

    createDummy(Hero.TRACER, Team.2, -1, vect(-19.06, 13.48, -88.07), vect(0.23, 0, -0.97))
    insideSmugglerNpc = getLastCreatedEntity()
    insideSmugglerNpc.startForcingName("Smuggler")
    createDummy(Hero.TRACER, Team.2, -1, vect(-44.52, 4.49, -49.63), vect(0.54, 0, 0.84))
    outsideSmugglerNpc = getLastCreatedEntity()
    outsideSmugglerNpc.startForcingName("Smuggler")

    createDummy(Hero.ASHE, Team.2, -1, vect(-54.65, 1.73, -131.02), vect(0.87, 0, -0.49))
    bartenderNpc = getLastCreatedEntity()
    bartenderNpc.startForcingName("Bartender")

    getPlayers(Team.2).setStatusEffect(null, Status.INVINCIBLE, INF)

rule "Global setup":
    @Event global

    # disableInspector()
    disableAnnouncer()
    disableGamemodeCompletion()
    setObjectiveDescription(getAllPlayers(), "Escape", HudReeval.VISIBILITY_AND_STRING)
    startForcingSpawn(Team.2, 2)
    getAllPlayers().disableNameplatesFor(getAllPlayers())

    # cutscene skip text
    hudSubtext(skipCutscenePlayers, "Press {0} to skip".format(buttonString(Button.JUMP)), HudPosition.TOP, 10, rgba(127, 127, 127, localPlayer.skipAlpha), HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.NEVER)

    # intro text
    createInWorldText(introStage1Players, "You had a plan", vect(45.98, 11.47, -71.48) + vect(-1, -0.01, 0.10), 50, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(introStage1Players, "And now you're stuck", vect(-36.85, 6.07, -72.38) + vect(0.55, 0.12, 0.83), 50, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(introStage2Players, "Escape", vect(-35.24, 13.01, -55.88), 50, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(introStage2Players, "from", vect(-35.24, 12.51, -55.88), 50, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)

    # equipped hud text
    hudHeader(equipPlayers[Equip.HAS_ANY], "Equipped", HudPosition.LEFT, 1, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(equipPlayers[Equip.LITTLE_BUDDY], "{0} Little buddy".format(abilityIconString(Hero.ROADHOG, Button.ULTIMATE)), HudPosition.LEFT, 2, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(equipPlayers[Equip.SUNSCREEN], "{0} Sunscreen".format(abilityIconString(Hero.ROADHOG, Button.ABILITY_2)), HudPosition.LEFT, 3, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(equipPlayers[Equip.SUNGLASES], "{0} Sunglasses".format(abilityIconString(Hero.WINSTON, Button.ULTIMATE)), HudPosition.LEFT, 4, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(equipPlayers[Equip.DISGUISE], "{0} Hilarious Costume".format(abilityIconString(Hero.LUCIO, Button.ULTIMATE)), HudPosition.LEFT, 5, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(equipPlayers[Equip.WINGS], "{0} Mechanical wings".format(abilityIconString(Hero.MERCY, Button.ULTIMATE)), HudPosition.LEFT, 6, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)

    # achievement hud text
    hudHeader(achievementPlayers[Achievement.HAS_ANY], "Achievements", HudPosition.RIGHT, 1, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.MOST_WANTED], "Most wanted {0}".format(abilityIconString(Hero.MCCREE, Button.ULTIMATE)), HudPosition.RIGHT, 2, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.INFRASIGHT], "Infrasight {0}".format(abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE)), HudPosition.RIGHT, 3, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.PUZZLE_MASTER], "Puzzle master {0}".format(abilityIconString(Hero.LUCIO, Button.JUMP)), HudPosition.RIGHT, 4, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.IN_A_HURRY], "In a hurry {0}".format(abilityIconString(Hero.SOLDIER, Button.ABILITY_1)), HudPosition.RIGHT, 5, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.MASTER_HACKER], "Master hacker {0}".format(abilityIconString(Hero.SOMBRA, Button.SECONDARY_FIRE)), HudPosition.RIGHT, 6, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.ESCAPE_ARTIST], "Escape artist {0}".format(abilityIconString(Hero.BAPTISTE, Button.ULTIMATE)), HudPosition.RIGHT, 7, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)

    createInWorldText(getAllPlayers(), "Enter", vect(-55.67, 9.57, -82.45), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(getAllPlayers(), "Enter", vect(-66.45, 11.56, -80.28), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)

    # tutorial text
    hudSubtext(graphicsQualityPlayers, "Certain details are only visible with graphics quality medium or higher", HudPosition.TOP, 0, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudSubtext(graphicsQualityPlayers, "Change the setting under Settings > Video > Graphics Quality", HudPosition.TOP, 1, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    createInWorldText(tutorialTextPlayers[TutorialText.INTERACT], "Use {0} to interact with things".format(buttonString(Button.PRIMARY_FIRE)), vect(-101.13, 12.35, -80.42), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(tutorialTextPlayers[TutorialText.INV_CYCLE], "Use {0} / {1} to cycle inventory items".format(buttonString(Button.ULTIMATE), buttonString(Button.ABILITY_2)), vect(-88.78, 12.51, -90.72), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(tutorialTextPlayers[TutorialText.APPLY_ITEM], "Use {0} to use inventory items on things".format(buttonString(Button.SECONDARY_FIRE)), vect(-100.28, 13.26, -90.12), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(tutorialTextPlayers[TutorialText.HINTS], "Use {0} to activate the hint system".format(buttonString(Button.RELOAD)), vect(-112.74, 11.88, -100.54), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

    # tutorial gate
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-99.01, 10.93, -91.03), localPlayer.tutorialGate1End, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-99.01, 10.93, -91.03) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 1, localPlayer.tutorialGate1End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 1, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-99.01, 10.93, -91.03) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 2, localPlayer.tutorialGate1End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 2, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-99.01, 10.93, -91.03) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 3, localPlayer.tutorialGate1End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 3, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-99.01, 10.93, -91.03) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 4, localPlayer.tutorialGate1End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 4, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-99.01, 10.93, -91.03) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 5, localPlayer.tutorialGate1End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 5, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-94.20, 10.93, -92.04), localPlayer.tutorialGate2End, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-94.20, 10.93, -92.04) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 1, localPlayer.tutorialGate2End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 1, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-94.20, 10.93, -92.04) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 2, localPlayer.tutorialGate2End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 2, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-94.20, 10.93, -92.04) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 3, localPlayer.tutorialGate2End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 3, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-94.20, 10.93, -92.04) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 4, localPlayer.tutorialGate2End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 4, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(tutorialPlayers, Beam.TORBJORN_TURRET_SIGHT, vect(-94.20, 10.93, -92.04) + vect(0, TUTORIAL_GATE_OFFSET, 0) * 5, localPlayer.tutorialGate2End + vect(0, TUTORIAL_GATE_OFFSET, 0) * 5, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    createEffect(tutorialPlayers, Effect.ZARYA_PARTICLE_BEAM_SOUND, null, localPlayer.getPosition(), (5 - distance(vect(-100.32, 11.44, -90.75), localPlayer.getPosition())) * 30, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(tutorialPlayers, Effect.ZARYA_PARTICLE_BEAM_SOUND, null, localPlayer.getPosition(), (5 - distance(vect(-92.97, 11.44, -92.29), localPlayer.getPosition())) * 30, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    # inner wire connection
    createBeam(innerWirePlayers, Beam.GRAPPLE, vect(-106.59, 12.46, -135.78), vect(-107.26, 12.50, -135.87), null, EffectReeval.VISIBILITY)

    # power panel
    createEffect(powerPanelPlayers[0], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.392, 14.145, -137.307), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[0], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.394, 14.145, -137.316), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[0], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.396, 14.145, -137.325), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[0], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.398, 14.145, -137.334), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[0], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.400, 14.145, -137.343), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[0], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.402, 14.145, -137.352), 0.013, EffectReeval.VISIBILITY)

    createEffect(powerPanelPlayers[1], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.392, 14.071, -137.307), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[1], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.394, 14.071, -137.316), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[1], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.396, 14.071, -137.325), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[1], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.398, 14.071, -137.334), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[1], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.400, 14.071, -137.343), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[1], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.402, 14.071, -137.352), 0.013, EffectReeval.VISIBILITY)

    createEffect(powerPanelPlayers[2], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.392, 13.998, -137.307), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[2], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.394, 13.998, -137.316), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[2], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.396, 13.998, -137.325), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[2], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.398, 13.998, -137.334), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[2], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.400, 13.998, -137.343), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[2], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.402, 13.998, -137.352), 0.013, EffectReeval.VISIBILITY)

    createEffect(getAllPlayers(), Effect.SPHERE, POWER_BROKEN_COLOR, vect(-111.392, 13.914, -137.307), 0.013, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.SPHERE, POWER_BROKEN_COLOR, vect(-111.394, 13.914, -137.316), 0.013, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.SPHERE, POWER_BROKEN_COLOR, vect(-111.396, 13.914, -137.325), 0.013, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.SPHERE, POWER_BROKEN_COLOR, vect(-111.398, 13.914, -137.334), 0.013, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.SPHERE, POWER_BROKEN_COLOR, vect(-111.400, 13.914, -137.343), 0.013, EffectReeval.VISIBILITY)
    createEffect(getAllPlayers(), Effect.SPHERE, POWER_BROKEN_COLOR, vect(-111.402, 13.914, -137.352), 0.013, EffectReeval.VISIBILITY)

    createEffect(powerPanelPlayers[4], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.392, 13.835, -137.307), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[4], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.394, 13.835, -137.316), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[4], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.396, 13.835, -137.325), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[4], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.398, 13.835, -137.334), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[4], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.400, 13.835, -137.343), 0.013, EffectReeval.VISIBILITY)
    createEffect(powerPanelPlayers[4], Effect.SPHERE, POWER_OFF_COLOR, vect(-111.402, 13.835, -137.352), 0.013, EffectReeval.VISIBILITY)

    # window 0
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-80.91, 8.29, -97.13), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-80.91, 8.79, -97.13), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-80.91, 9.29, -97.13), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-80.91, 9.79, -97.13), 5, EffectReeval.VISIBILITY)

    # window 1
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-98.09, 8.11, -113.37), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.83, 8.11, -112.13), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.57, 8.11, -110.89), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.30, 8.11, -109.65), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.04, 8.11, -108.41), 5, EffectReeval.VISIBILITY)

    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-98.09, 9.89, -113.37), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.83, 9.89, -112.13), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.57, 9.89, -110.89), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.30, 9.89, -109.65), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.04, 9.89, -108.41), 5, EffectReeval.VISIBILITY)

    # window 2
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.94, 8.72, -120.05), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.74, 8.72, -119.11), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.54, 8.72, -118.17), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.34, 8.72, -117.23), 5, EffectReeval.VISIBILITY)

    # window 3
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-101.44, 8.11, -129.02), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-101.18, 8.11, -127.78), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.92, 8.11, -126.54), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.66, 8.11, -125.30), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.40, 8.11, -124.06), 5, EffectReeval.VISIBILITY)

    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-101.44, 9.89, -129.02), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-101.18, 9.89, -127.78), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.92, 9.89, -126.54), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.66, 9.89, -125.30), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.40, 9.89, -124.06), 5, EffectReeval.VISIBILITY)

    # window 4
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.18, 7.97, -138.75), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.03, 7.97, -138.04), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.88, 7.97, -137.33), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.73, 7.97, -136.62), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.58, 7.97, -135.91), 5, EffectReeval.VISIBILITY)

    # window 5
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.32, 14.01, -140.24), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.16, 14.01, -139.46), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.00, 14.01, -138.68), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.83, 14.01, -137.90), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.67, 14.01, -137.12), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.51, 14.01, -136.33), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.34, 14.01, -135.55), 5, EffectReeval.VISIBILITY)

    # # window 6
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.36, 14.01, -151.78), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.79, 14.01, -151.12), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-98.23, 14.01, -150.45), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-98.67, 14.01, -149.78), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.11, 14.01, -149.11), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.54, 14.01, -148.44), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.98, 14.01, -147.77), 5, EffectReeval.VISIBILITY)

    # window 7
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-92.30, 11, -169.23), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-92.30, 11.5, -169.23), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-92.30, 12, -169.23), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-92.30, 12.5, -169.23), 3, EffectReeval.VISIBILITY)

    # inner workbench puzzle
    createEffect(innerMinigamePlayers, Effect.SPHERE, Color.GRAY, vect(-103.45, 8.89, -184.36), 0.04, EffectReeval.VISIBILITY)
    createEffect(innerMinigamePlayers, Effect.SPHERE, Color.GRAY, vect(-103.50, 8.89, -184.63), 0.04, EffectReeval.VISIBILITY)
    createBeam(innerMinigamePlayers, Beam.TORBJORN_TURRET_SIGHT, INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6) * 0.2, 0.451 + cos(PI / 6) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6 + 2 * PI / 3) * 0.2, 0.451 + cos(PI / 6 + 2 * PI / 3) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(innerMinigamePlayers, Beam.TORBJORN_TURRET_SIGHT, INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6 + 2 * PI / 3) * 0.2, 0.451 + cos(PI / 6 + 2 * PI / 3) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6 + 4 * PI / 3) * 0.2, 0.451 + cos(PI / 6 + 4 * PI / 3) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(innerMinigamePlayers, Beam.TORBJORN_TURRET_SIGHT, INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6 + 4 * PI / 3) * 0.2, 0.451 + cos(PI / 6 + 4 * PI / 3) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6) * 0.2, 0.451 + cos(PI / 6) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(innerMinigamePlayers, Effect.SPHERE, Color.BLACK, INNER_MINIGAME_2D_TO_3D(vect(1.48, 0.73, 0)), 0.05, EffectReeval.VISIBILITY)
    createInWorldText(innerMinigamePlayers, "skip", INNER_MINIGAME_2D_TO_3D(vect(1.48, 0.73 + 0.04, 0)), 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(innerMinigamePlayers, "Use the gray dots to make the arrow point the other way", vect(-103.48, 9.64, -184.53), 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)

    # radio smoke effect
    createEffect(radioSmokePlayers, Effect.CLOUD, Color.BLACK, vect(-90.05, 8.69, -103.28), 0.1, EffectReeval.VISIBILITY)

    # outer workbench puzzle
    createEffect(outerMinigamePlayers, Effect.SPHERE, Color.GRAY, OUTER_MINIGAME_2D_TO_3D(vect(0.92, 0.08 + 0.17 / 3, 0)), 0.03, EffectReeval.VISIBILITY)
    createEffect(outerMinigamePlayers, Effect.SPHERE, Color.GRAY, OUTER_MINIGAME_2D_TO_3D(vect(0.52, 0.08 + 0.17 / 3, 0)), 0.03, EffectReeval.VISIBILITY)
    createEffect(outerMinigamePlayers, Effect.SPHERE, Color.GRAY, OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17 * 7 / 3, 0)), 0.03, EffectReeval.VISIBILITY)
    createEffect(outerMinigamePlayers, Effect.SPHERE, Color.BLACK, OUTER_MINIGAME_2D_TO_3D(vect(1.15, 0.59, 0)), 0.05, EffectReeval.VISIBILITY)
    createInWorldText(outerMinigamePlayers, "skip", OUTER_MINIGAME_2D_TO_3D(vect(1.15, 0.59 + 0.04, 0)), 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(outerMinigamePlayers, "Turn all the red dots black. Click the gray dots to rotate the surrounding ones.", vect(-56.46, 12.81, -60.53), 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)

    # map marker
    createEffect(mapMarkerPlayers, Effect.SPHERE, Color.RED, vect(-88.04, 13.37, -158.22), 0.5, EffectReeval.VISIBILITY)

    # barn paper clues
    createEffect(barnHintPlayers, Effect.SPARKLES, Color.YELLOW, vect(58.30, 8.3, -93.83), 0.3, EffectReeval.VISIBILITY)
    createEffect(barnHintPlayers, Effect.SPARKLES, Color.YELLOW, vect(42.25, 15.3, -71.88), 0.3, EffectReeval.VISIBILITY)

    # barn workbench puzzle
    for I in range(len(barnMinigameConnections)):
        for J in range(len(barnMinigameConnections[I])):
            if I < barnMinigameConnections[I][J]:
                createBeam(barnMinigamePlayers, Beam.GRAPPLE, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[I]), BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[barnMinigameConnections[I][J]]), null, EffectReeval.VISIBILITY)

    createEffect(barnMinigamePlayers, Effect.SPHERE, Color.BLACK, BARN_MINIGAME_2D_TO_3D(vect(1.4, 0.8, 0)), 0.05, EffectReeval.VISIBILITY)
    createInWorldText(barnMinigamePlayers, "skip", BARN_MINIGAME_2D_TO_3D(vect(1.4, 0.8 + 0.04, 0)), 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(barnMinigamePlayers, "Swap the positions of the black and white dots", vect(48.86, 11.14, -81.48), 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)

    # sat control
    createEffect(satControlPlayers, Effect.SPHERE, Color.BLUE, OUTSIDE_SAT_TO_WORLD(vect(0.1, 0.1, 0)), 0.05, EffectReeval.VISIBILITY)
    createEffect(satControlPlayers, Effect.SPHERE, Color.BLUE, OUTSIDE_SAT_TO_WORLD(vect(1.7, 0.1, 0)), 0.05, EffectReeval.VISIBILITY)
    createEffect(satControlPlayers, Effect.SPHERE, Color.BLUE, OUTSIDE_SAT_TO_WORLD(vect(0.1, 0.9, 0)), 0.05, EffectReeval.VISIBILITY)
    createEffect(satControlPlayers, Effect.SPHERE, Color.BLUE, OUTSIDE_SAT_TO_WORLD(vect(1.7, 0.9, 0)), 0.05, EffectReeval.VISIBILITY)

    # smuggler mail txt
    createInWorldText(insideMailTextPlayers, "You've got mail!", INSIDE_SMUGGLER_TEXT_LOCATION - vect(0, 0.1, 0), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)
    createInWorldText(outsideMailTextPlayers, "You've got mail!", OUTSIDE_SMUGGLER_TEXT_LOCATION - vect(0, 0.1, 0), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)

def innerMinigameInitialState():
    eventPlayer.isDoingInnerMinigame = false
    eventPlayer.isHoldingInnerMinigameControl1 = false
    eventPlayer.isHoldingInnerMinigameControl2 = false
    eventPlayer.innerMinigameValue1 = PI / 2
    eventPlayer.innerMinigameValue2 = PI / 2

def outerMinigameInitialState():
    eventPlayer.isDoingOuterMinigame = false
    eventPlayer.outerMinigameState = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    eventPlayer.outerMinigameMovesMade = 0

def barnMinigameInitialState():
    eventPlayer.isDoingBarnMinigame = false
    eventPlayer.barnMinigameColorState = [0, 1, 1, 1, 1, 2, 2, 2, 2]
    eventPlayer.barnMinigamePosState = [1, 2, 3, 4, 5, 6, 7, 8]

def playerInitialState():
    # Stop chasing
    stopChasingVariable(eventPlayer.X)
    stopChasingVariable(eventPlayer.Y)
    stopChasingVariable(eventPlayer.Z)
    stopChasingVariable(eventPlayer.T)
    stopChasingVariable(eventPlayer.tStart)
    stopChasingVariable(eventPlayer.tEnd)
    stopChasingVariable(eventPlayer.tPos)
    stopChasingVariable(eventPlayer.innerMinigameValue1)
    stopChasingVariable(eventPlayer.innerMinigameValue2)
    stopChasingVariable(eventPlayer.bruceTimer)
    stopChasingVariable(eventPlayer.tutorialGate1End)
    stopChasingVariable(eventPlayer.tutorialGate2End)
    stopChasingVariable(eventPlayer.skipAlpha)

    eventPlayer.stopFacing()
    eventPlayer.clearStatusEffect(Status.ROOTED)

    # Player state
    eventPlayer.pauseInteraction = false

    eventPlayer.junkPos = vect(-95.58, 12.17, -86.79)
    eventPlayer.junkFacing = vect(0.21, 0.08, 0.97)

    eventPlayer.hogPos = vect(68.39, 13.91, -86.84)
    eventPlayer.hogFacing = vect(0.86, -0.51, 0)

    eventPlayer.isJunk = false
    eventPlayer.isHog = false

    eventPlayer.junkInventory = []
    eventPlayer.hogInventory = []
    eventPlayer.inventory = []

    eventPlayer.junkEquipped = []
    eventPlayer.hogEquipped = []
    eventPlayer.equipped = []

    eventPlayer.insideSmugglerItem = null
    eventPlayer.outsideSmugglerItem = null

    eventPlayer.money = 0

    eventPlayer.achievements = []

    # Game state
    eventPlayer.tutorialFinished = false
    eventPlayer.wiresConnected = false
    eventPlayer.generatorOn = false
    eventPlayer.powerSwitched = false
    eventPlayer.lightsOn = false

    innerMinigameInitialState()
    eventPlayer.hasFinishedInnerMinigame = false

    eventPlayer.hasFoundInnerRadio = false
    eventPlayer.canBeTheOtherGuy = false

    eventPlayer.numVentsClosed = 0
    eventPlayer.hasSunglasses = false
    eventPlayer.hasSunscreen = false
    eventPlayer.canGoOutside = false

    outerMinigameInitialState()
    eventPlayer.hasFinishedOuterMinigame = false

    # generate random 5 digit code
    eventPlayer.barnCode = [random.randint(0, 5 ** 5 - 1)]
    eventPlayer.barnCode.append(eventPlayer.barnCode[0] % 5 ** 4)
    eventPlayer.barnCode[0] = floor(eventPlayer.barnCode[0] / 5 ** 4) + 1
    eventPlayer.barnCode.append(eventPlayer.barnCode[1] % 5 ** 3)
    eventPlayer.barnCode[1] = floor(eventPlayer.barnCode[1] / 5 ** 3) + 1
    eventPlayer.barnCode.append(eventPlayer.barnCode[2] % 5 ** 2)
    eventPlayer.barnCode[2] = floor(eventPlayer.barnCode[2] / 5 ** 2) + 1
    eventPlayer.barnCode.append(eventPlayer.barnCode[3] % 5 ** 1)
    eventPlayer.barnCode[3] = floor(eventPlayer.barnCode[3] / 5 ** 1) + 1
    eventPlayer.barnCode[4]++

    eventPlayer.barnCodeInputted = []
    eventPlayer.canAccessBarnSecret = false
    eventPlayer.canLeaveBarn = false

    eventPlayer.canUtilizeSmuggler = false

    barnMinigameInitialState()
    eventPlayer.hasFinishedBarnMinigame = false

    eventPlayer.molePersonRiddleLine = 0
    eventPlayer.molePersonInteractStage = 0

    eventPlayer.bruceTimer = 0

    eventPlayer.hasFinishedGame = false

    eventPlayer.isDoingHint = false

    eventPlayer.postersFound = []
    eventPlayer.outsideMapFound = false
    eventPlayer.timesBruceClicked = 0

    # Item points

    # enum Item:
    #     ID,              # unique item id (descriptive string)
    #     STATE,           # state of the item (int)
    #     POINT,           # location of the item (vect)
    #     RADIUS,          # radius for item interaction (float)
    #     MESSAGE,         # messages for item based on state (string array)
    #     ITEM_NAME,       # name of received item if interacted with (string)
    #     PLAY_GET_SOUND,  # whether to play interaction sound (bool)
    #     NEEDS_LOS,       # whether los is needed to interact (bool)
    #     REMOVE_ON_STATE, # state at which the point is removed (int)
    #
    #     # item use points use the fields below
    #     REQUIRED_ITEM,   # item required to use with this point based on state (string array, matches with ITEM_NAME)
    #     SUCCESS_MESSAGE  # message to play on successful item use based on state (string array)

    # Interaction points
    eventPlayer.tutGate1 = [Id.tutGate1, 0, vect(-100.32, 11.44, -90.75), 1.5, ["The lasers would slice you up if you tried to go through"], null, null, null, 1, ["Rusty key"], ["How does a key open a laser gate? You aren't one to think about it too hard"]]
    eventPlayer.tutGate2 = [Id.tutGate2, 0, vect(-92.97, 11.44, -92.29), 1.5, ["The lasers would slice you up if you tried to go through"], null, null, null, 1, ["Rusty key"], null]

    eventPlayer.innerWires = [Id.innerWires, 0, vect(-106.91, 12.44, -135.82), 0.4, ["The unconnected wires are sparking", "The wires are connected"], null, null, null, null, ["Extension cord"], ["You connect the wires"]]
    eventPlayer.innerBarrel2 = [Id.innerBarrel2, 0, vect(-103.58, 7.02, -120.15), 0.5, ["There's a little bit of petrol pooled in the bottom", "The barrel is now completely empty"], null, null, null, null, ["Empty petrol can"], ["You fill up the petrol can with with the last of the petrol"]]
    eventPlayer.innerGenerator = [Id.innerGenerator, 0, vect(-109.58, 13.83, -132.75), 2.5, ["The generator is cold and lifeless", "The generator needs fuel to run", "The generator hums with a dim energy"], null, null, null, null, ["Fuel filled petrol can", "Fuel filled petrol can"], ["You pour the petrol into the generator", "You pour the petrol into the generator"]]

    eventPlayer.innerRadio = [Id.innerRadio, 0, vect(-90.05, 8.69, -103.28), 0.3, ["A radio to the outside. It seems to be missing a fiddly part though", "The radio is busted. Oops"], null, null, null, null, null, null]
    eventPlayer.innerWorkbench = [Id.innerWorkbench, 0, vect(-103.41, 8.67, -184.58), 1, null, null, null, null, null, ["Fiddly part"], ["This should help you reverse the polarity of the fiddly part"]]
    eventPlayer.innerToolbox2 = [Id.innerToolbox2, 0, vect(-103.00, 8.01, -182.63), 0.75, ["It's locked"], null, true, null, null, ["Vent key"], ["The toolbox unlocks. Inside you find some ancient sunscreen"]]

    eventPlayer.outerWorkbench = [Id.outerWorkbench, 0, vect(-56.45, 11.90, -60.51), 1, null, null, null, null, null, ["Red battery"], ["This should help you change the color of the battery"]]
    eventPlayer.outerBruce = [Id.outerBruce, 0, vect(-21.62, 7.48, -104.95), 1, null]
    eventPlayer.outerSmuggler = [Id.outerSmuggler, 0, vect(-19.06, 14.48, -88.07), 1, null]
    eventPlayer.outerBartender = [Id.outerBartender, 0, vect(-54.65, 2.73, -131.02), 1, null]
    eventPlayer.outerNotSmuggler = [Id.outerNotSmuggler, 0, vect(-35.02, 2.48, -126.33), 1, null]
    eventPlayer.outerDoor21 = [Id.outerDoor21, 0, vect(-50.47, 13.63, -84.74), 1.1, null]
    eventPlayer.outerDoor22 = [Id.outerDoor22, 0, vect(-54.41, 13.63, -84.09), 1.1, null]
    eventPlayer.outerDoor23 = [Id.outerDoor23, 0, vect(-59.72, 13.63, -85.31), 1.1, null]
    eventPlayer.outerDoor24 = [Id.outerDoor24, 0, vect(-48.46, 13.63, -90.79), 1.1, null]
    eventPlayer.outerDoor25 = [Id.outerDoor25, 0, vect(-42.10, 14.63, -94.75), 1.1, null]

    eventPlayer.barnWorkbench = [Id.barnWorkbench, 0, vect(48.86, 10.21, -81.42), 1, null, null, null, null, null, ["Right handed remote"], ["This should help you make the remote left handed"]]

    eventPlayer.outsideHose = [Id.outsideHose, 0, vect(-31.21, 6.36, -27.83), 0.7, ["The hose leads down from the water tower", "You don't need any more water"], null, null, null, null, ["Empty petrol can"], ["You fill up the can with water"]]
    eventPlayer.outsideSatControl = [Id.outsideSatControl, 0, vect(-3.30, 14.20, -83.94), 1, ["This controls the satellite connection to your friend Bruce, but you left the necessary remote at his place", "You've already talked to Bruce"], null, null, null, null, ["Left handed remote"], ["You use the remote on the controller"]]
    eventPlayer.outsideSmuggler = [Id.outsideSmuggler, 0, vect(-44.52, 5.49, -49.63), 1, null]
    eventPlayer.outsideMolePersonRoom = [Id.outsideMolePersonRoom, 0, vect(-50.68, 5.97, -4.12), 2, null]
    eventPlayer.outsideMolePersonOuthouse = [Id.outsideMolePersonOuthouse, 0, MOLE_PERSON_OUTHOUSE_TEXT_LOCATION, 2, null]
    eventPlayer.outsideMolePersonCar = [Id.outsideMolePersonCar, 0, MOLE_PERSON_CAR_TEXT_LOCATION, 2, null]
    eventPlayer.outsideMolePersonCliff = [Id.outsideMolePersonCliff, 0, MOLE_PERSON_CLIFF_TEXT_LOCATION, 2, null]

    eventPlayer.itemPoints = [
        # tutorial room
        [Id.tutSafe1, 0, vect(-104.92, 12.06, -84.28), 1.2, ["All that's inside are a few dusty cobwebs"], null, true],
        [Id.tutSafe2, 0, vect(-100.95, 11.28, -80.59), 0.7, ["There's an odd looking coin in here"], "Odd looking coin", true],
        [Id.tutSafe3, 0, vect(-103.16, 11.95, -76.61), 1, ["The box is buried under a mound of coins and can't be opened"], null, true],
        [Id.tutSafe4, 0, vect(-89.28, 12.44, -72.22), 1.2, ["The door of the safe is too heavy to lift"], null, true],
        [Id.tutSafe5, 0, vect(-88.78, 11.51, -90.72), 0.7, ["The door squeaks open and you find a rusty key inside"], null, true],
        [Id.tutGold, 0, vect(-95.60, 11.38, -86.96), 1.5, ["Is this... how you were brought in here?"]],

        [Id.tutBarrel1, 0, vect(-100.70, 11.04, -77.17), 0.5, ["All of the barrels in here seem to be empty"]],
        [Id.tutBarrel2, 0, vect(-101.63, 11.30, -76.47), 0.5, ["All of the barrels in here seem to be empty"]],
        [Id.tutBarrel3, 0, vect(-101.72, 11.70, -75.09), 0.5, ["All of the barrels in here seem to be empty"]],
        [Id.tutBarrel4, 0, vect(-88.59, 11.70, -73.35), 0.5, ["All of the barrels in here seem to be empty"]],
        [Id.tutBarrel5, 0, vect(-83.85, 11.78, -80.16), 0.5, ["All of the barrels in here seem to be empty"]],
        [Id.tutBarrel6, 0, vect(-87.39, 11.07, -84.29), 0.5, ["All of the barrels in here seem to be empty"]],
        [Id.tutBarrel7, 0, vect(-88.16, 10.97, -85.22), 0.5, ["All of the barrels in here seem to be empty"]],

        # lights on section
        [Id.innerFridge, 0, vect(-110.04, 6.97, -111.51), 1.1, ["All that's inside are fish heads and moldy leftovers"], null, true],
        [Id.innerChest1, 0, vect(-114.91, 7.07, -124.08), 1.2, ["There's an empty petrol can inside, just free for the taking"], "Empty petrol can", true],
        [Id.innerLocker1, 0, vect(-112.76, 7.55, -134.80), 1.2, ["Whoever's locker this was didn't have the decency to leave easily stolen goods inside"], null, true],
        [Id.innerLocker2, 0, vect(-113.80, 7.55, -139.10), 1.2, ["There's a note: \"Keep your hands off my stuff you scrawny eyed mole rats!\""], null, true],
        [Id.innerLocker3, 0, vect(-112.58, 7.55, -141.24), 1.2, ["The locker is completely devoid of utility"], null, true],
        [Id.innerLocker4, 0, vect(-108.08, 7.55, -142.79), 1.2, ["There's an old extension cord hidden in the back"], "Extension cord", true],
        [Id.innerLocker5, 0, vect(-106.71, 7.55, -141.16), 1.2, ["You don't even want to think about whose swimsuit that is"], null, true],
        [Id.innerPowerDistributor, 0, vect(-110.71, 13.19, -136.03), 0.8, ["This power distribution unit sends power from the generator to the panel above"]],

        [Id.innerBarrel1, 0, vect(-113.43, 7.02, -116.14), 0.5, ["The barrel is as dry as a day in December"], null, true],
        [Id.innerBarrel3, 0, vect(-105.32, 12.79, -132.71), 0.5, ["It's as empty as the depths of your soul"], null, true],
        [Id.innerNotBarrel, 0, vect(-104.5, 7.64, -121.27), 1, ["This doesn't hold petrol, but maybe if you look nearby"]],

        [Id.innerSwitch1, 0, vect(-111.46, 14.145, -137.47), 0.05, null],
        [Id.innerSwitch2, 0, vect(-111.46, 14.071, -137.47), 0.05, null],
        [Id.innerSwitch3, 0, vect(-111.46, 13.994, -137.47), 0.05, null],
        [Id.innerSwitch4, 0, vect(-111.46, 13.914, -137.47), 0.05, null],
        [Id.innerSwitch5, 0, vect(-111.46, 13.835, -137.47), 0.05, null],
        [Id.innerPowerBox, 0, vect(-111.73, 14.04, -137.34), 0.5, ["This is the power switching box for the whole area", "Maybe if you get the generator running you can turn the lights on", "There's no power going to the box"]],

        # larger inner section
        eventPlayer.innerRadio, # higher up for priority reasons

        [Id.innerThrone, 0, vect(-88.94, 8.40, -102.99), 0.75, ["The queen's throne... oh how you want to sit on it"]],

        [Id.innerChest2, 0, vect(-101.16, 8.12, -198.06), 1.2, ["You pick up a battery covered in peeling red paint"], "Red battery", true],
        [Id.innerToolbox1, 0, vect(-103.25, 9.22, -182.63), 0.75, ["There's a note: \"Threw key in vent by entrance gate. Long as the three valves are open, no one can grab it.\""], null, true],
        [Id.innerSmallToolbox1, 0, vect(-102.65, 9.06, -181.25), 0.5, ["Someone just left a fiddly part in the toolbox? It must be your lucky day"], "Fiddly part", true],
        [Id.innerTireRack, 0, vect(-87.96, 8.63, -201.60), 1.8, ["Why are there rubber tires when all the cars hover?"]],

        [Id.innerBrokenMech1, 0, vect(-88.35, 8.26, -142.03), 2, ["The mech seems to be missing a limb. You sympathize with it"]],
        [Id.innerBrokenMech2, 0, vect(-75.42, 8.52, -146.11), 2, ["This mech doesn't even have a saw blade on it"]],
        [Id.innerMech1, 0, vect(-90.47, 10.09, -177.75), 2, ["Now *that's* a sawblade"]],
        [Id.innerMech2, 0, vect(-94.87, 10.11, -178.01), 2, ["The old king's mech. You've never seen it up close before"]],

        [Id.innerMinigameControl1, 0, vect(-103.45, 8.89, -184.36), 0.1, null],
        [Id.innerMinigameControl2, 0, vect(-103.50, 8.89, -184.63), 0.1, null],
        [Id.innerMinigameSkip, 0, INNER_MINIGAME_2D_TO_3D(vect(1.48, 0.73, 0)), 0.05, null],

        [Id.innerSunglasses, 0, vect(-88.04, 13.37, -158.22), 1, ["You find some tattered sunglasses hidden in the corner", "You've already scoured this area"]],

        [Id.innerValve1, 0, vect(-85.83, 8.43, -178.64), 0.5, [null, "The valve is already closed"]],
        [Id.innerValve2, 0, vect(-54.84, 9.57, -143.66), 0.5, [null, "The valve is already closed"]],
        [Id.innerValve3, 0, vect(-53.58, 9.91, -122.34), 0.5, [null, "The valve is already closed"]],

        [Id.innerVent1, 0, vect(-108.61, 10.46, -108.17), 1, ["You don't see anything in here"]],
        [Id.innerVent2, 0, vect(-84.87, 11.34, -186.75), 1, ["You don't see anything in here"]],
        [Id.innerVent3, 0, vect(-54.90, 10.74, -125.39), 1, null],
        [Id.innerVent4, 0, vect(-75.87, 14.17, -123.53), 2, ["You don't see anything in here"]],
        [Id.innerVent5, 0, vect(-69.87, 15.81, -107.26), 1, ["You don't see anything in here"]],
        [Id.innerVent6, 0, vect(-94.74, 13.59, -177.53), 1, ["You don't see anything in here"]],
        [Id.innerVent7, 0, vect(-86.38, 14.14, -180.01), 1.8, ["You don't see anything in here"]],


        # courtyard area
        [Id.outerIceBox, 0, vect(-50.77, 2.49, -126.77), 1, ["The harsh look from the bartender keeps you from poking around inside"], null, true],
        [Id.outerSmallToolbox1, 0, vect(-11.03, 8.29, -103.06), 0.5, ["The toolbox is far too heavy for its size"], null, true],
        [Id.outerToolbox1, 0, vect(-61.25, 11.55, -75.41), 0.75, ["This looks like a... frog mask? You may as well put it on"], null, true],
        [Id.outerToolbox2, 0, vect(-9.54, 8.40, -104.89), 0.75, ["You don't know what half these tools do. Okay, all of them"], null, true],
        [Id.outerToolbox3, 0, vect(-10.33, 7.33, -102.96), 0.75, ["You find an old remote inside"], "Right handed remote", true],
        [Id.outerRadio, 0, vect(-10.46, 8.35, -105.80), 0.3, ["This allows incoming connections from outside as long as they're broadcasting on the right frequency"]],
        [Id.outerMic, 0, vect(-30.95, 3.80, -135.05), 0.5, null],
        [Id.outerWaterBarrel, 0, vect(-17.72, 7.95, -90.27), 3, ["You've never been able to figure out how to get water out of here"]],

        [Id.outerCart, 0, vect(-41.66, 6.20, -66.89), 3, ["The cart is stopped in the middle of the road"]],

        [Id.outerPoster1, 0, vect(-64.74, 8.68, -102.96), 0.8, ["A grossly unfair characterization"], null, null, true],
        [Id.outerPoster2, 0, vect(-60.39, 14.28, -88.06), 0.5, ["You don't want to be here anyway"], null, null, true],
        [Id.outerPoster3, 0, vect(-48.70, 8.39, -95.52), 0.8, ["It was all just a big misunderstanding"], null, null, true],
        [Id.outerPoster4, 0, vect(-45.22, 8.42, -112.92), 0.5, ["The Queen was too attached to that summer shack anyway"], null, null, true],
        [Id.outerPoster5, 0, vect(-42.93, 8.67, -116.01), 0.5, ["Really, you were doing her a favor"], null, null, true],
        [Id.outerPoster6, 0, vect(-41.97, 14.58, -120.91), 0.5, ["The picture has your nose all wrong"], null, null, true],
        [Id.outerPoster7, 0, vect(-26.17, 14.43, -112.75), 0.5, ["Come on, what's a few explosions between friends"], null, null, true],
        [Id.outerPoster8, 0, vect(-20.13, 8.15, -95.48), 0.7, ["And you thought this used to be a respectable establishment"], null, null, true],
        [Id.outerPoster9, 0, vect(-32.28, 7.78, -94.74), 0.5, ["This is completely unnecessary"], null, null, true],
        [Id.outerPoster10, 0, vect(-31.35, 7.44, -85.96), 1.1, ["Don't people deserve a sixth chance?"], null, null, true],
        [Id.outerPosterOob11, 0, vect(-44.65, 6.38, -76.55), 0.7, ["\"Troublemakers\"? The nerve"], null, null, true],
        [Id.outerPosterOob12, 0, vect(-35.80, 5.70, -70.76), 1, ["You feel wounded at such accusations"], null, null, true],
        [Id.outerPosterOob13, 0, vect(-44.66, 6.73, -60.23), 1.1, ["Maybe if you just had a little chat with the Queen"], null, null, true],
        [Id.outerPosterOob14, 0, vect(-33.01, 5.96, -63.99), 0.7, ["There's no need to go to such extremes"], null, null, true],
        [Id.outerPosterOob15, 0, vect(-54.26, 5.98, -47.88), 0.7, ["What's the point of putting a poster all the way over here?"], null, null, true],

        [Id.outerBinoculars, 0, vect(-36.64, 14.02, -59.19), 0.3],

        [Id.outerMinigameDot1, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17 * 3, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot2, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.62, 0.08 + 0.17 * 2, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot3, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.82, 0.08 + 0.17 * 2, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot4, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.52, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot5, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot6, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.92, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot7, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.42, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot8, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.62, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot9, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.82, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameDot10, 0, OUTER_MINIGAME_2D_TO_3D(vect(1.02, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        [Id.outerMinigameRotate1, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17 * 7 / 3, 0)), 0.08, null],
        [Id.outerMinigameRotate2, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.52, 0.08 + 0.17 / 3, 0)), 0.08, null],
        [Id.outerMinigameRotate3, 0, OUTER_MINIGAME_2D_TO_3D(vect(0.92, 0.08 + 0.17 / 3, 0)), 0.08, null],
        [Id.outerMinigameSkip, 0, OUTER_MINIGAME_2D_TO_3D(vect(1.15, 0.59, 0)), 0.05, null],


        # barn area
        [Id.barnRadio, 0, vect(69.46, 15.15, -86.83), 0.7, ["That idiot managed to blow up the only working radio"]],
        [Id.barnTvPanel, 0, vect(70.40, 15.44, -82.28), 0.4, ["You don't need to change the TV channel right now"]],
        [Id.barnPachimari, 0, vect(69.81, 10.58, -80.19), 1.2, ["Despite your love for them, you were never any good at these things"]],
        [Id.barnFuelMachine, 0, vect(69.01, 10.34, -84.15), 1.2, ["This machine helps you survive the irradiated outdoors"], null, true],
        [Id.barnFridge, 0, vect(66.91, 10.37, -67.64), 1, ["The fridge is full of half eaten Chinese food"], null, true],
        [Id.barnTireRack, 0, vect(44.07, 10.12, -88.71), 1.5, ["This rack of hover pads is entirely unremarkable"], null, null, true],
        [Id.barnPlan, 0, vect(44.03, 11.11, -71.35), 1.5, ["Things didn't to according to plan"], null, null, true],

        [Id.barnToolbox1, 0, vect(49.62, 10.55, -75.25), 0.75, ["The toolbox is filled with a bunch of spare spark plugs"], null, true],
        [Id.barnToolbox2, 0, vect(50.55, 9.42, -75.90), 0.75, ["There's a meticulously arranged collection of screwdrivers, but nothing you need right now"], null, true],
        [Id.barnSmallToolbox1, 0, vect(49.20, 10.27, -79.17), 0.5, ["This was always your least favorite toolbox"], null, true],
        [Id.barnSafe1, 0, vect(60.60, 10.01, -65.34), 1, ["That's private, there's no need to look in there"], null, true, true],
        [Id.barnSafe2, 0, vect(60.52, 9.50, -63.60), 0.8, ["You pick up your little buddy and place him carefully in your bag"], null, true],
        [Id.barnSafe3, 0, vect(56.13, 9.74, -62.70), 0.7, ["This safe is empty, you just put it there for the aesthetic"], null, true, true],
        [Id.barnEmptyShelf, 0, vect(50.05, 10.56, -63.46), 2, ["Times have been rough lately"], null, true, true],

        [Id.barnPaperClue1, 0, vect(58.30, 9, -93.83), 0.3, null],
        [Id.barnPaperClue2, 0, vect(42.25, 16, -71.88), 0.3, null],
        [Id.barnBike, 0, vect(54.56, 10.65, -78.11), 2.5, null],

        [Id.barnSwitch1, 0, vect(56.48, 10.655, -66.584), 0.05, null],
        [Id.barnSwitch2, 0, vect(56.48, 10.581, -66.584), 0.05, null],
        [Id.barnSwitch3, 0, vect(56.48, 10.504, -66.584), 0.05, null],
        [Id.barnSwitch4, 0, vect(56.48, 10.424, -66.584), 0.05, null],
        [Id.barnSwitch5, 0, vect(56.48, 10.345, -66.584), 0.05, null],
        [Id.barnCodePanel, 0, vect(56.55, 10.50, -66.74), 0.5, ["This opens your secret stash, if only you could remember the code"]],

        [Id.barnMinigameDot0, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[0]), 0.05, null],
        [Id.barnMinigameDot1, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[1]), 0.05, null],
        [Id.barnMinigameDot2, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[2]), 0.05, null],
        [Id.barnMinigameDot3, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[3]), 0.05, null],
        [Id.barnMinigameDot4, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[4]), 0.05, null],
        [Id.barnMinigameDot5, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[5]), 0.05, null],
        [Id.barnMinigameDot6, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[6]), 0.05, null],
        [Id.barnMinigameDot7, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[7]), 0.05, null],
        [Id.barnMinigameDot8, 0, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[8]), 0.05, null],
        [Id.barnMinigameSkip, 0, BARN_MINIGAME_2D_TO_3D(vect(1.4, 0.8, 0)), 0.05, null],


        # larger outside area
        eventPlayer.outsideHose, # here for priority reasons

        [Id.outsideJunkWorkbench, 0, vect(31.57, 10.71, -95.93), 1.2, ["That idiot was always working on some dumb scheme"]],
        [Id.outsideSafe, 0, vect(21.24, 10.90, -88.37), 0.7, ["You don't what to know what kind of stuff he keeps in there"], null, true],
        [Id.outsideIceBox, 0, vect(-32.99, 5.36, -29.36), 1, ["It smells like something's rotted in there"], null, true, true],
        [Id.outsideFridge1, 0, vect(20.48, 11.05, -95.08), 1, ["There's a map with a the word \"sunglasses\" pointing to a red dot"]],
        [Id.outsideFridge2, 0, vect(-5.68, 13.51, -74.65), 1.2, ["Without electricity, this fridge isn't doing a very good job"], null, true],
        [Id.outsideFridge3, 0, vect(-31.79, 5.62, -28.84), 0.8, ["You can't open the door"], null, true, true],
        [Id.outsideFridge4, 0, vect(-31.72, 5.57, -30.10), 0.8, ["The door won't budge"], null, true, true],
        [Id.outsideToolbox1, 0, vect(-6.67, 8.55, -77.17), 0.7, ["There's only some ancient pistons in here"], null, true],
        [Id.outsideToolbox2, 0, vect(-6.55, 7.60, -77.18), 0.7, ["You don't need any of the car parts inside since you have a motorcycle"], null, true],
        [Id.outsideSmallToolbox, 0, vect(24.28, 9.26, -64.30), 0.5, ["It seems to hold the moldy remains of someone's lunch"], null, true],
        [Id.outsideChest1, 0, vect(19.26, 8.73, -55.36), 1.2, ["Anything in here has been looted a long time ago"], null, true],
        [Id.outsideChest2, 0, vect(-7.98, 8.35, -47.93), 1.2, ["It might be useful for standing on, but not much else"], null, true],
        [Id.outsideChest3, 0, vect(-7.98, 6.58, -47.93), 1.2, ["This chest is trapped under the other one"], null, true],
        [Id.outsideChest4, 0, vect(-35.12, 5.22, -43.65), 1.2, ["The only things inside are some half dead brambles"], null, true],
        [Id.outsideChest5, 0, vect(-50.83, 4.92, -16.62), 1.2, ["Nothing up your sleeve, or in the chest"], null, true],

        [Id.outsidePoster1, 0, vect(-30.90, 6.14, -60.22), 0.8, ["That idiot is always getting you in trouble"], null, null, true],
        [Id.outsidePoster2, 0, vect(-23.46, 6.70, -66.49), 0.8, ["There's not much you need in there, but you'll miss talking to Bruce"], null, null, true],

        # item apply points
        eventPlayer.tutGate1,
        eventPlayer.tutGate2,

        eventPlayer.innerWires,
        eventPlayer.innerBarrel2,
        eventPlayer.innerGenerator,
        # eventPlayer.innerRadio, # higher up for priority reasons
        eventPlayer.innerWorkbench,
        eventPlayer.innerToolbox2,

        eventPlayer.outerBruce,
        eventPlayer.outerSmuggler,
        eventPlayer.outerBartender,
        eventPlayer.outerNotSmuggler,
        eventPlayer.outerWorkbench,
        eventPlayer.outerDoor21,
        eventPlayer.outerDoor22,
        eventPlayer.outerDoor23,
        eventPlayer.outerDoor24,
        eventPlayer.outerDoor25,

        eventPlayer.barnWorkbench,

        eventPlayer.outsideSatControl,
        eventPlayer.outsideSmuggler,
        # eventPlayer.outsideHose, # higher up for priority reasons
        eventPlayer.outsideMolePersonRoom,
        eventPlayer.outsideMolePersonOuthouse,
        eventPlayer.outsideMolePersonCar,
        eventPlayer.outsideMolePersonCliff,
    ]

    eventPlayer.itemIds = [elem[Item.ID] for elem in eventPlayer.itemPoints]

    # Other state setup
    introStage1Players.remove(eventPlayer)
    introStage2Players.remove(eventPlayer)

    # tutorial gate setup
    eventPlayer.tutorialGate1End = vect(-101.64, 10.93, -90.46)
    eventPlayer.tutorialGate2End = vect(-91.58, 10.93, -92.60)

    eventPlayer.inventoryPlayer = []

    manageEquips()
    manageAchievements()

    tutorialTextPlayers[TutorialText.INTERACT].remove(eventPlayer)
    tutorialTextPlayers[TutorialText.INTERACT].append(eventPlayer)
    tutorialTextPlayers[TutorialText.INV_CYCLE].remove(eventPlayer)
    tutorialTextPlayers[TutorialText.APPLY_ITEM].remove(eventPlayer)
    tutorialTextPlayers[TutorialText.HINTS].remove(eventPlayer)
    tutorialPlayers.remove(eventPlayer)
    tutorialPlayers.append(eventPlayer)
    graphicsQualityPlayers.remove(eventPlayer)

    playersInDark.remove(eventPlayer)

    innerWirePlayers.remove(eventPlayer)

    powerPanelPlayers[0].remove(eventPlayer)
    powerPanelPlayers[0].append(eventPlayer)
    powerPanelPlayers[1].remove(eventPlayer)
    powerPanelPlayers[1].append(eventPlayer)
    powerPanelPlayers[2].remove(eventPlayer)
    powerPanelPlayers[2].append(eventPlayer)
    powerPanelPlayers[3].remove(eventPlayer)
    powerPanelPlayers[3].append(eventPlayer)
    powerPanelPlayers[4].remove(eventPlayer)
    powerPanelPlayers[4].append(eventPlayer)

    innerMinigamePlayers.remove(eventPlayer)
    radioSmokePlayers.remove(eventPlayer)

    outerMinigamePlayers.remove(eventPlayer)

    mapMarkerPlayers.remove(eventPlayer)

    barnHintPlayers.remove(eventPlayer)
    barnHintPlayers.append(eventPlayer)

    barnMinigamePlayers.remove(eventPlayer)

    dvdLogoPlayers.remove(eventPlayer)
    dvdLogoPlayers.append(eventPlayer)
    satControlPlayers.remove(eventPlayer)

    insideMailTextPlayers.remove(eventPlayer)
    outsideMailTextPlayers.remove(eventPlayer)

    eventPlayer.startForcingHero(Hero.JUNKRAT)
    eventPlayer.teleport(eventPlayer.junkPos)
    eventPlayer.setFacing(eventPlayer.junkFacing, Relativity.TO_WORLD)
    wait(RACE_CONDITION_DELAY)
    eventPlayer.isJunk = true

def resetGame():
    FADE_TO_BLACK()

    popAllEffectDeleteQueue()
    popAllTextDeleteQueue()
    playerInitialState()

    eventPlayer.currentCutscene = Cutscene.WAKING

rule "Show intro cutscenes":
    @Event playerJoined
    @Team 1

    eventPlayer.isCutsceneFinished = false
    eventPlayer.currentCutscene = Cutscene.INTRO

rule "Initial player setup":
    @Event playerJoined
    @Team 1

    playerInitialState()

    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INF)
    eventPlayer.setInvisibility(Invis.ENEMIES)
    eventPlayer.disableGamemodeHud()
    eventPlayer.disableScoreboard()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableMessages()

    hudHeader(eventPlayer.inventoryPlayer, "Inventory: {0}".format(eventPlayer.inventory), HudPosition.LEFT, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

rule "Cleanup state on player leave":
    @Event playerLeft

    skipCutscenePlayers.remove(eventPlayer)
    introStage1Players.remove(eventPlayer)
    introStage2Players.remove(eventPlayer)
    tutorialPlayers.remove(eventPlayer)
    graphicsQualityPlayers.remove(eventPlayer)
    playersInDark.remove(eventPlayer)
    innerWirePlayers.remove(eventPlayer)
    innerMinigamePlayers.remove(eventPlayer)
    radioSmokePlayers.remove(eventPlayer)
    outerMinigamePlayers.remove(eventPlayer)
    barnHintPlayers.remove(eventPlayer)
    mapMarkerPlayers.remove(eventPlayer)
    barnMinigamePlayers.remove(eventPlayer)
    dvdLogoPlayers.remove(eventPlayer)
    satControlPlayers.remove(eventPlayer)
    insideMailTextPlayers.remove(eventPlayer)
    outsideMailTextPlayers.remove(eventPlayer)

    for eventPlayer.I in range(len(powerPanelPlayers)):
        powerPanelPlayers[eventPlayer.I].remove(eventPlayer)

    for eventPlayer.I in range(len(tutorialTextPlayers)):
        tutorialTextPlayers[eventPlayer.I].remove(eventPlayer)

    for eventPlayer.I in range(len(equipPlayers)):
        equipPlayers[eventPlayer.I].remove(eventPlayer)

    for eventPlayer.I in range(len(achievementPlayers)):
        achievementPlayers[eventPlayer.I].remove(eventPlayer)



# CUTSCENES

rule "skip cutscene text":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene != Cutscene.NONE

    skipCutscenePlayers.append(eventPlayer)
    stopChasingVariable(eventPlayer.skipAlpha)
    eventPlayer.skipAlpha = 255
    wait(5)
    chase(eventPlayer.skipAlpha, 0, duration=0.6, ChaseReeval.NONE)
    wait(0.6)
    skipCutscenePlayers.remove(eventPlayer)

rule "skip cutscene":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene != Cutscene.NONE
    @Condition eventPlayer.isHoldingButton(Button.JUMP)

    eventPlayer.isCutsceneFinished = true
    skipCutscenePlayers.remove(eventPlayer)

rule "show intro":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.INTRO and not eventPlayer.isCutsceneFinished

    wait(1, Wait.ABORT_WHEN_FALSE)
    hideUi()
    eventPlayer.setInvisibility(Invis.ALL)
    introStage1Players.append(eventPlayer)

    FADE_TO_BLACK()

    wait(3.5, Wait.ABORT_WHEN_FALSE)

    # Stage 1, view of plan
    eventPlayer.tPos = vect(45.98, 11.12, -71.48) + vect(-1, -0.01, 0.10) * 0.3
    eventPlayer.startCamera(eventPlayer.tPos, vect(45.98, 11.12, -71.48) + vect(-1, -0.01, 0.10), 0)
    chase(eventPlayer.tPos, vect(45.98, 11.12, -71.48) - vect(-1, -0.01, 0.10) * 0.2, duration=3.3, ChaseReeval.DESTINATION_AND_DURATION)

    wait(3.3, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)

    # Stage 2, following cart path
    smallMessage(eventPlayer, "But something went wrong")

    eventPlayer.bezier = [
        vect(7.60, 8.28, -68.38),
        vect(8.22, 8.32, -64.54),
        vect(8.84, 8.36, -60.69),
        vect(6.69, 8.28, -56.59),
        vect(4.54, 8.20, -52.48),
        vect(-0.38, 8.00, -48.11),
        vect(-5.31, 7.79, -43.75),
    ]
    eventPlayer.bezierDuration = 1.65
    eventPlayer.startCamera(BEZIER_POSITION, BEZIER_FACING, 0)
    doBezierArray()

    # Stage 3, view of posters
    eventPlayer.tPos = vect(-36.85, 5.72, -72.38) + vect(0.55, 0.12, 0.83) * 0.3
    eventPlayer.startCamera(eventPlayer.tPos, vect(-36.85, 5.72, -72.38) + vect(0.55, 0.12, 0.83), 0)
    chase(eventPlayer.tPos, vect(-36.85, 5.72, -72.38) - vect(0.55, 0.12, 0.83) * 0.2, duration=3.3, ChaseReeval.DESTINATION_AND_DURATION)

    wait(3.3, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)

    # Stage 4
    introStage1Players.remove(eventPlayer)

    eventPlayer.tPos = vect(26.97, 21.97, 47.25)
    eventPlayer.startCamera(eventPlayer.tPos, vect(-35.24, 11.71, -55.88), 0)
    chase(eventPlayer.tPos, vect(-33.71, 11.70, -53.29), duration=2.80, ChaseReeval.DESTINATION_AND_DURATION)

    wait(4.6, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)

    # Title view
    introStage2Players.append(eventPlayer)
    playEffect(eventPlayer, DynamicEffect.JUNKRAT_RIP_TIRE_EXPLOSION, null, vect(-35.24, 12.71, -55.88), 10)
    playEffect(eventPlayer, DynamicEffect.JUNKRAT_RIP_TIRE_EXPLOSION_SOUND, null, vect(-35.24, 12.71, -55.88), 80)

    wait(4, Wait.ABORT_WHEN_FALSE)

    FADE_TO_BLACK()

    introStage2Players.remove(eventPlayer)

    eventPlayer.isCutsceneFinished = true

rule "show intro cleanup":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.INTRO and eventPlayer.isCutsceneFinished

    eventPlayer.currentCutscene = Cutscene.NONE
    eventPlayer.isCutsceneFinished = false

    stopChasingVariable(eventPlayer.tPos)
    introStage1Players.remove(eventPlayer)
    introStage2Players.remove(eventPlayer)
    eventPlayer.setInvisibility(Invis.NONE)

    resetGame()

#!define INTRO_SPACING "\n                                                                                                                     "

rule "do waking animation":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.WAKING and not eventPlayer.isCutsceneFinished

    freeze()
    hideUi()
    FADE_TO_BLACK()
    wait(2, Wait.ABORT_WHEN_FALSE)

    CREATE_BLACK_TEXT("What... happened?" INTRO_SPACING, -2)
    wait(3, Wait.ABORT_WHEN_FALSE)
    CREATE_BLACK_TEXT("The last thing you remember is pushing the cart to the gate" INTRO_SPACING, -1)
    wait(3, Wait.ABORT_WHEN_FALSE)
    CREATE_BLACK_TEXT("Then a pain from behind" INTRO_SPACING, 0)
    wait(3, Wait.ABORT_WHEN_FALSE)
    CREATE_BLACK_TEXT("And..." INTRO_SPACING, 1)
    wait(2, Wait.ABORT_WHEN_FALSE)
    destroyInWorldText(eventPlayer.textDeleteQueue[len(eventPlayer.textDeleteQueue) - 1])
    del eventPlayer.textDeleteQueue[len(eventPlayer.textDeleteQueue) - 1]
    CREATE_BLACK_TEXT("And... a fuzzy face?" INTRO_SPACING, 1)
    wait(6, Wait.ABORT_WHEN_FALSE)

    eventPlayer.isCutsceneFinished = true

rule "do waking animation cleanup":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.WAKING and eventPlayer.isCutsceneFinished

    eventPlayer.currentCutscene = Cutscene.NONE
    eventPlayer.isCutsceneFinished = false

    eventPlayer.inventoryPlayer.append(eventPlayer)
    unfreeze()
    showUi()
    eventPlayer.stopCamera()
    popAllTextDeleteQueue()
    wait(3)
    graphicsQualityPlayers.append(eventPlayer)

#!define RADIO_TEXT_POS vect(-90.05, 8.69 + 0.3, -103.28)

rule "do inner radio conversation":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.INNER_RADIO and not eventPlayer.isCutsceneFinished

    freeze()

    smallMessage(eventPlayer, "You attempt to contact the other guy")

    wait(3, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("*krssshksht*", RADIO_TEXT_POS)
    createEffect(eventPlayer, Effect.MERCY_DAMAGE_BOOSTED_SOUND, null, eventPlayer.innerRadio[Item.POINT], 100, EffectReeval.NONE)
    pushEffectDeleteQueue()

    wait(2, Wait.ABORT_WHEN_FALSE)
    popEffectDeleteQueue()
    popTextDeleteQueue()

    wait(2, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("...what did you get yourself into this time.", RADIO_TEXT_POS)

    wait(5, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("You woke up in a safe full of gold?", RADIO_TEXT_POS)

    wait(5, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("In the queen's treasure room?!", RADIO_TEXT_POS)

    wait(5, Wait.ABORT_WHEN_FALSE)
    popTextDeleteQueue()
    wait(1, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("        \n.", RADIO_TEXT_POS)
    wait(1, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("        \n. .", RADIO_TEXT_POS)
    wait(1, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("        \n. . .", RADIO_TEXT_POS)
    wait(2, Wait.ABORT_WHEN_FALSE)
    popTextDeleteQueue()

    wait(2, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("Well, just try to get outside right now.", RADIO_TEXT_POS)

    wait(5, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("Find Bruce, he might be able to help you.", RADIO_TEXT_POS)

    wait(5, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("I'll let him know to expect you, he doesn't trust strangers.", RADIO_TEXT_POS)

    wait(5, Wait.ABORT_WHEN_FALSE)
    popTextDeleteQueue()

    wait(3, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("What? No an explosion won't hel-", RADIO_TEXT_POS)

    wait(1)
    popTextDeleteQueue()
    playEffect(eventPlayer, DynamicEffect.JUNKRAT_RIP_TIRE_EXPLOSION, null, eventPlayer.innerRadio[Item.POINT], 100)
    playEffect(eventPlayer, DynamicEffect.JUNKRAT_RIP_TIRE_EXPLOSION_SOUND, null, eventPlayer.innerRadio[Item.POINT], 100)
    radioSmokePlayers.append(eventPlayer)
    wait(2)
    smallMessage(eventPlayer, "Oops")
    wait(5, Wait.ABORT_WHEN_FALSE)
    eventPlayer.isCutsceneFinished = true

rule "do inner radio conversation cleanup":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.INNER_RADIO and eventPlayer.isCutsceneFinished

    eventPlayer.currentCutscene = Cutscene.NONE
    eventPlayer.isCutsceneFinished = false

    smallMessage(eventPlayer, "Press {0} to be the other guy".format(buttonString(Button.INTERACT)))
    eventPlayer.canBeTheOtherGuy = true
    if eventPlayer not in radioSmokePlayers:
        radioSmokePlayers.append(eventPlayer)
    unfreeze()
    popAllEffectDeleteQueue()
    popAllTextDeleteQueue()

rule "do comedy routine":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.COMEDY and not eventPlayer.isCutsceneFinished

    freeze()
    smallMessage(eventPlayer, "You walk up on stage and everyone starts laughing")
    wait(5, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, "But you haven't even told any jokes yet?")
    wait(5, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, "You rip the mask off in disgust")
    wait(5, Wait.ABORT_WHEN_FALSE)
    smallMessage(eventPlayer, "She tells you that's enough and waves you over")

    eventPlayer.isCutsceneFinished = true

rule "do comedy routine cleanup":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.COMEDY and eventPlayer.isCutsceneFinished

    eventPlayer.currentCutscene = Cutscene.NONE
    eventPlayer.isCutsceneFinished = false

    unfreeze()
    eventPlayer.equipped.remove(Equip.DISGUISE)
    manageEquips()

def doBruceContact():
    dvdLogoPlayers.remove(eventPlayer)
    wait(0.5)
    satControlPlayers.append(eventPlayer)

    eventPlayer.tStart = 0 # beam angle
    eventPlayer.tEnd = 0.1 # center sphere radius

    createBeam(eventPlayer, Beam.MERCY_BOOST, OUTSIDE_SAT_TO_WORLD(vect(0.1, 0.1, 0)), OUTSIDE_SAT_TO_WORLD(vect(0.1 + sin(eventPlayer.tStart), 0.1 + cos(eventPlayer.tStart) * 0.9, 0)), Color.TEAM_1, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createBeam(eventPlayer, Beam.MERCY_BOOST, OUTSIDE_SAT_TO_WORLD(vect(1.7, 0.1, 0)), OUTSIDE_SAT_TO_WORLD(vect(1.7 - sin(eventPlayer.tStart), 0.1 + cos(eventPlayer.tStart) * 0.9, 0)), Color.TEAM_1, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createBeam(eventPlayer, Beam.MERCY_BOOST, OUTSIDE_SAT_TO_WORLD(vect(0.1, 0.9, 0)), OUTSIDE_SAT_TO_WORLD(vect(0.1 + sin(eventPlayer.tStart), 0.9 - cos(eventPlayer.tStart) * 0.9, 0)), Color.TEAM_1, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createBeam(eventPlayer, Beam.MERCY_BOOST, OUTSIDE_SAT_TO_WORLD(vect(1.7, 0.9, 0)), OUTSIDE_SAT_TO_WORLD(vect(1.7 - sin(eventPlayer.tStart), 0.9 - cos(eventPlayer.tStart) * 0.9, 0)), Color.TEAM_1, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()

    wait(1)
    chase(eventPlayer.tStart, 1.107, duration=3, ChaseReeval.NONE)

    wait(3)
    createEffect(eventPlayer, Effect.SPHERE, Color.WHITE, OUTSIDE_SAT_TO_WORLD(vect(0.9, 0.5, 0)), updateEveryTick(eventPlayer.tEnd), EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()

    wait(2)
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    satControlPlayers.remove(eventPlayer)

    chase(eventPlayer.tEnd, 0, duration=0.3, ChaseReeval.NONE)

    wait(0.3)
    popEffectDeleteQueue()

    stopChasingVariable(eventPlayer.tStart)
    stopChasingVariable(eventPlayer.tEnd)

def doMoleLeaderInteractionStage1():
    freeze()

    eventPlayer.tPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()
    chase(eventPlayer.tPos, DOOR_24_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.tPos), 9999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

    CREATE_TEXT("Seek first the room beneath the outer wall.\nIf no one's there, return back to this hall.", DOOR_24_TEXT_LOCATION)
    wait(0.5)

    stopChasingVariable(eventPlayer.tPos)
    eventPlayer.stopFacing()
    unfreeze()

def doMoleLeaderInteractionStage2():
    freeze()

    eventPlayer.tPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()
    chase(eventPlayer.tPos, DOOR_24_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.tPos), 9999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

    CREATE_TEXT("Look next behind the old unused latrine.\nNot in the open, but the one less seen.", DOOR_24_TEXT_LOCATION)
    wait(0.5)

    stopChasingVariable(eventPlayer.tPos)
    eventPlayer.stopFacing()
    unfreeze()

def doMoleLeaderInteractionStage3():
    freeze()

    eventPlayer.tPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()
    chase(eventPlayer.tPos, DOOR_24_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.tPos), 9999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

    CREATE_TEXT("Beneath the two stacked cars you next should comb,\nalthough it can be hardly called a home.", DOOR_24_TEXT_LOCATION)
    wait(0.5)

    stopChasingVariable(eventPlayer.tPos)
    eventPlayer.stopFacing()
    unfreeze()

def doMoleLeaderInteractionStage4():
    freeze()

    eventPlayer.tPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()
    chase(eventPlayer.tPos, DOOR_24_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.tPos), 9999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

    CREATE_TEXT("The final place we know is by the cliff\nwhere sewage drains, you'll know it if you sniff.", DOOR_24_TEXT_LOCATION)
    wait(0.5)

    stopChasingVariable(eventPlayer.tPos)
    eventPlayer.stopFacing()
    unfreeze()

rule "do mole leader interaction":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.MOLE_LEADER_INTERACTION and not eventPlayer.isCutsceneFinished

    freeze()
    hideUi()

    eventPlayer.tPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()
    chase(eventPlayer.tPos, DOOR_24_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)

    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.tPos), 9999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    CREATE_TEXT("Ahh...", DOOR_24_TEXT_LOCATION)
    wait(2, Wait.ABORT_WHEN_FALSE)
    CREATE_TEXT("You've found the thing we need to free ourselves", DOOR_24_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    chase(eventPlayer.tPos, DOOR_21_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    CREATE_TEXT("from shackles long endured and sorrows wept.", DOOR_21_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    chase(eventPlayer.tPos, DOOR_23_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    CREATE_TEXT("The walls around this city hem us in", DOOR_23_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    chase(eventPlayer.tPos, DOOR_25_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    CREATE_TEXT("but we must not expose our secrets kept.", DOOR_25_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    chase(eventPlayer.tPos, DOOR_24_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    CREATE_TEXT("And so we ask your aid in our endeavor:", DOOR_24_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    chase(eventPlayer.tPos, DOOR_22_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    CREATE_TEXT("Bring this device outside the barren gate", DOOR_22_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    chase(eventPlayer.tPos, DOOR_23_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    CREATE_TEXT("to one who hides amongst the dust with fervor-", DOOR_23_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    chase(eventPlayer.tPos, DOOR_25_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    CREATE_TEXT("then we shall help you passages locate.", DOOR_25_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    eventPlayer.isCutsceneFinished = true

rule "do mole leader interaction cleanup":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.MOLE_LEADER_INTERACTION and eventPlayer.isCutsceneFinished

    eventPlayer.currentCutscene = Cutscene.NONE
    eventPlayer.isCutsceneFinished = false

    eventPlayer.inventory.remove("Odd looking coin")
    GIVE_ITEM(MOLE_PERSON_DEVICE_NAME)

    popTextDeleteQueue()
    stopChasingVariable(eventPlayer.tPos)
    eventPlayer.stopFacing()
    showUi()
    unfreeze()

    doMoleLeaderInteractionStage1()

rule "do mole agent interaction":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.MOLE_AGENT_INTERACTION and not eventPlayer.isCutsceneFinished

    freeze()

    CREATE_TEXT("Eep! Is that what I think it is?", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(3, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("I never thought I'd see it... squiz", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(3, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("Sorry, I was never any good at the whole riddle thing.\n", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(3, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("Sorry, I was never any good at the whole riddle thing.\nMaybe that's why they sent me out here.", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(5, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("*Sigh*", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(2, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("It's nothing you need to worry about though.\nThanks for getting the device out of Junkertown.", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(6, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("Tell your friend I'm sorry for knocking him out and stuffing\nhim into the safe.", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(5, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("Gold's the only thing the Queen lets in the vault, so there\nwas no other way in.", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(5, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("And that's where she was keeping the Device.", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    popTextDeleteQueue()
    wait(2, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("I'll let the others know you've delivered it.", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    CREATE_TEXT("They'll get your friend where he needs to go.", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(4, Wait.ABORT_WHEN_FALSE)

    popTextDeleteQueue()

    # eventPlayer.tPos = MOLE_PERSON_CLIFF_TEXT_LOCATION + vect(0, 1, 0)
    # createBeam(eventPlayer, Beam.ECHO_FOCUSING, MOLE_PERSON_CLIFF_TEXT_LOCATION, eventPlayer.tPos, Color.TEAM_1, EffectReeval.POSITION_AND_RADIUS)
    # pushEffectDeleteQueue()
    # wait(2)
    # chase(eventPlayer.tPos, MOLE_PERSON_CLIFF_TEXT_LOCATION + vect(0, 100, 0), rate=10, ChaseReeval.NONE)

    # wait(4)

    # popEffectDeleteQueue()
    # createBeam(eventPlayer, Beam.TORBJORN_TURRET_SIGHT, MOLE_PERSON_CLIFF_TEXT_LOCATION, MOLE_PERSON_CLIFF_TEXT_LOCATION + vect(0, 100, 0), Color.TEAM_1, EffectReeval.NONE)
    # pushEffectDeleteQueue()

    # wait(5)

    eventPlayer.isCutsceneFinished = true

rule "do mole agent interaction cleanup":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.MOLE_AGENT_INTERACTION and eventPlayer.isCutsceneFinished

    eventPlayer.currentCutscene = Cutscene.NONE
    eventPlayer.isCutsceneFinished = false

    popTextDeleteQueue()
    unfreeze()

rule "do ending cutscene":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.ENDING and not eventPlayer.isCutsceneFinished

    freeze()
    hideUi()

    eventPlayer.tPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()
    chase(eventPlayer.tPos, DOOR_24_TEXT_LOCATION, duration=0.5, ChaseReeval.DESTINATION_AND_DURATION)
    eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.tPos), 9999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

    CREATE_TEXT("      A device, stolen\n Our people, liberated\nAnd you, the way out", DOOR_24_TEXT_LOCATION)
    wait(0.5, Wait.ABORT_WHEN_FALSE)

    stopChasingVariable(eventPlayer.tPos)
    wait(5, Wait.ABORT_WHEN_FALSE)
    popTextDeleteQueue()

    FADE_TO_BLACK()
    wait(3, Wait.ABORT_WHEN_FALSE)

    # walk along path
    eventPlayer.bezier = [
        vect(-37.02, 33.22, -123.09),
        vect(-38.33, 33.22, -121.57),
        vect(-39.65, 33.22, -120.05),
        vect(-41.69, 33.22, -118.41),
        vect(-43.72, 33.22, -116.78),
        vect(-46.47, 33.22, -115.02),
        vect(-49.22, 33.22, -113.27),
    ]
    eventPlayer.bezierDuration = 3
    eventPlayer.startCamera(BEZIER_POSITION, BEZIER_FACING, 0)
    doBezierArray()

    wait(0.5, Wait.ABORT_WHEN_FALSE)

    # look up at ladder
    eventPlayer.tPos = BEZIER_POSITION
    eventPlayer.tEnd = eventPlayer.tPos + vect(-0.84, 0, 0.54)

    eventPlayer.startCamera(eventPlayer.tPos, eventPlayer.tEnd, 0)
    chase(eventPlayer.tEnd, eventPlayer.tPos + vect(0, 10, -1), duration=3, ChaseReeval.NONE)
    wait(4, Wait.ABORT_WHEN_FALSE)
    stopChasingVariable(eventPlayer.tEnd)

    # climb ladder looking right
    eventPlayer.bezier = [
        vect(-49.22, 33.22, -113.27),
        vect(-48.90, 35.69, -112.71),
        vect(-48.58, 38.15, -112.15),
        vect(-48.46, 40.97, -111.93),
        vect(-48.34, 43.79, -111.71),
        vect(-48.41, 46.96, -111.83),
        vect(-48.53, 49.74, -112.06),
    ]
    eventPlayer.bezierDuration = 3
    eventPlayer.startCamera(BEZIER_POSITION, BEZIER_POSITION + vect(0.99, 0, -0.16), 10)
    doBezierArray()

    # climb ladder looking up
    eventPlayer.bezier = [
        vect(-48.53, 49.74, -112.06),
        vect(-48.65, 52.52, -112.29),
        vect(-48.83, 54.90, -112.63),
        vect(-49.20, 57.42, -113.32),
        vect(-49.58, 59.94, -114.01),
        vect(-50.16, 62.59, -115.05),
        vect(-50.73, 65.25, -116.09),
    ]
    eventPlayer.bezierDuration = 3
    eventPlayer.startCamera(BEZIER_POSITION, BEZIER_FACING, 3)
    doBezierArray()

    wait(0.5, Wait.ABORT_WHEN_FALSE)

    # look to right
    eventPlayer.tPos = vect(-50.73, 65.25, -116.09)
    eventPlayer.tEnd = eventPlayer.tPos + vect(-2.068, 8.620, -3.829)

    eventPlayer.startCamera(eventPlayer.tPos, eventPlayer.tEnd, 5)
    chase(eventPlayer.tEnd, vect(-50.73, 65.25, -116.09) + (vect(-48.03, 65.26, -116.94) - vect(-50.73, 65.25, -116.09)) * 2, duration=1.5, ChaseReeval.NONE)
    wait(2.5, Wait.ABORT_WHEN_FALSE)
    stopChasingVariable(eventPlayer.tEnd)

    # walk to jump off point
    chase(eventPlayer.tPos, vect(-48.03, 65.26, -116.94), duration=1, ChaseReeval.NONE)
    wait(1.5, Wait.ABORT_WHEN_FALSE)

    # look over city
    eventPlayer.tEnd = vect(-50.73, 65.25, -116.09) + (vect(-48.03, 65.26, -116.94) - vect(-50.73, 65.25, -116.09)) * 20
    eventPlayer.startCamera(vect(-48.03, 65.26, -116.94), eventPlayer.tEnd, 5)
    chase(eventPlayer.tEnd, vect(-30, 25, -36), duration=5, ChaseReeval.NONE)
    wait(6, Wait.ABORT_WHEN_FALSE)

    chase(eventPlayer.tEnd, vect(23, 33, -80), duration=3, ChaseReeval.NONE)
    wait(4, Wait.ABORT_WHEN_FALSE)

    chase(eventPlayer.tEnd, vect(-48.03, 65.26, -116.94) + vect(4.80, -30.51, 46.04), duration=2, ChaseReeval.NONE)
    wait(5, Wait.ABORT_WHEN_FALSE)

    # fly over walls
    eventPlayer.bezier = [
        vect(-48.03, 65.26, -116.94),
        vect(-47.62, 61.24, -110.82),
        vect(-47.22, 57.21, -104.71),
        vect(-42.88, 53.43, -99.76),
        vect(-38.54, 49.65, -94.81),
        vect(-30.27, 46.12, -91.03),
        vect(-19.10, 41.99, -93.56),
        vect(-7.94, 37.87, -96.08),
        vect(6.11, 33.16, -104.90),
        vect(23.30, 29.13, -109.77),
        vect(40.49, 25.09, -114.64),
        vect(60.81, 21.74, -115.56),
        vect(72.50, 19.39, -110.53),
        vect(84.19, 17.05, -105.50),
        vect(87.24, 15.72, -94.52),
        vect(97.07, 13.29, -81.67),
        vect(106.90, 10.86, -68.81),
        vect(123.52, 7.35, -54.09),
        vect(140.66, 4.80, -56.95),
        vect(157.80, 2.25, -59.81),
        vect(175.47, 0.67, -80.25),
        vect(193.15, -0.91, -100.69),
    ]
    eventPlayer.bezierDuration = 2
    eventPlayer.startCamera(BEZIER_POSITION, BEZIER_FACING, 0)
    doBezierArray()

    wait(2, Wait.ABORT_WHEN_FALSE)

    eventPlayer.isCutsceneFinished = true

def doCredits():
    FADE_TO_BLACK()
    wait(1)

    bigMessage(eventPlayer, "Achievement get! Escape artist: get out of Junkertown")
    eventPlayer.achievements.append(Achievement.ESCAPE_ARTIST)

    eventPlayer.tText = " "
    if Achievement.MOST_WANTED in eventPlayer.achievements:
        eventPlayer.tText = "{0}{1} ".format(eventPlayer.tText, abilityIconString(Hero.MCCREE, Button.ULTIMATE))
    if Achievement.INFRASIGHT in eventPlayer.achievements:
        eventPlayer.tText = "{0}{1} ".format(eventPlayer.tText, abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE))
    if Achievement.PUZZLE_MASTER in eventPlayer.achievements:
        eventPlayer.tText = "{0}{1} ".format(eventPlayer.tText, abilityIconString(Hero.LUCIO, Button.JUMP))
    if Achievement.IN_A_HURRY in eventPlayer.achievements:
        eventPlayer.tText = "{0}{1} ".format(eventPlayer.tText, abilityIconString(Hero.SOLDIER, Button.ABILITY_1))
    if Achievement.MASTER_HACKER in eventPlayer.achievements:
        eventPlayer.tText = "{0}{1} ".format(eventPlayer.tText, abilityIconString(Hero.SOMBRA, Button.SECONDARY_FIRE))
    if Achievement.ESCAPE_ARTIST in eventPlayer.achievements:
        eventPlayer.tText = "{0}{1} ".format(eventPlayer.tText, abilityIconString(Hero.BAPTISTE, Button.ULTIMATE))

    wait(5)

    eventPlayer.tPos = -1.6
    CREATE_MOVABLE_TEXT("Thanks for playing", 0, 1, Color.WHITE)
    CREATE_MOVABLE_TEXT("Escape from", 3, 2, Color.WHITE)
    CREATE_MOVABLE_TEXT("Junkertown", 5, 4, rgb(236, 190, 82))
    CREATE_MOVABLE_TEXT("Created by EruIluvatar", 8.75, 0.8, Color.WHITE)
    CREATE_MOVABLE_TEXT("Testing by Shiner237", 9.25, 0.8, Color.WHITE)
    CREATE_MOVABLE_TEXT("You got {0} of {1} achievements".format(len(eventPlayer.achievements), Achievement.END_MARKER - 1), 13, 2, Color.PURPLE)
    CREATE_MOVABLE_TEXT(eventPlayer.tText, 14.5, 1.5, Color.PURPLE)

    chase(eventPlayer.tPos, 0.8, rate=0.3, ChaseReeval.NONE)
    wait(8)
    stopChasingVariable(eventPlayer.tPos)

    wait(3)
    CREATE_MOVABLE_TEXT("Press {0} to restart".format(buttonString(Button.INTERACT)), 18, 1.5, Color.WHITE)
    eventPlayer.hasFinishedGame = true

rule "do ending cutscene cleanup":
    @Event eachPlayer
    @Condition eventPlayer.currentCutscene == Cutscene.ENDING and eventPlayer.isCutsceneFinished

    eventPlayer.currentCutscene = Cutscene.NONE
    eventPlayer.isCutsceneFinished = false

    stopChasingVariable(eventPlayer.tPos)
    stopChasingVariable(eventPlayer.tEnd)
    doCredits()



# PASSIVE ONGOING

rule "Set spawns":
    @Event playerDied

    eventPlayer.resurrect()
    if eventPlayer.isJunk:
        eventPlayer.teleport(vect(-95.58, 12.17, -86.79))
        eventPlayer.setFacing(vect(0.21, 0.08, 0.97), Relativity.TO_WORLD)
    else:
        eventPlayer.teleport(vect(59.23, 9, -77.60))
        eventPlayer.setFacing(vect(-1, 0, 0), Relativity.TO_WORLD)

rule "Update junk position and direction":
    @Event eachPlayer
    @Condition eventPlayer.isJunk

    eventPlayer.junkPos = eventPlayer.getPosition()
    eventPlayer.junkFacing = eventPlayer.getFacingDirection()
    wait(0.16, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

rule "Update hog position and direction":
    @Event eachPlayer
    @Condition eventPlayer.isHog

    eventPlayer.hogPos = eventPlayer.getPosition()
    eventPlayer.hogFacing = eventPlayer.getFacingDirection()
    wait(0.16, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

#!define SPAWN_CLIP_RADIUS 1.3
#!define NEXT_TO(pos) (distance(eventPlayer.getEyePosition(), pos) < SPAWN_CLIP_RADIUS)

rule "Walk through spawn protections enable":
    @Event eachPlayer
    @Condition NEXT_TO(vect(-55.57, 9, -82.41)) or NEXT_TO(vect(-66.38, 11, -80.21))

    eventPlayer.disableEnvironmentCollision(false)

rule "Walk through spawn protections disable":
    @Event eachPlayer
    @Condition not NEXT_TO(vect(-55.57, 9, -82.41)) and not NEXT_TO(vect(-66.38, 11, -80.21))

    eventPlayer.enableEnvironmentCollision()

# requires that all ncps are at least 10m apart
rule "Hide npc text":
    @Event eachPlayer
    @Condition distance(eventPlayer, BRUCE_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, INSIDE_SMUGGLER_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, OUTSIDE_SMUGGLER_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, BARTENDER_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, NOT_SMUGGLER_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, vect(-49.37, 13.63, -86.90)) > 12 or eventPlayer.getPosition().y < 12.40
    @Condition distance(eventPlayer, MOLE_PERSON_ROOM_TEXT_LOCATION) > 16
    @Condition distance(eventPlayer, MOLE_PERSON_OUTHOUSE_TEXT_LOCATION) > 12
    @Condition distance(eventPlayer, MOLE_PERSON_CAR_TEXT_LOCATION) > 16
    @Condition distance(eventPlayer, MOLE_PERSON_CLIFF_TEXT_LOCATION) > 16

    popTextDeleteQueue()



# STATE CHANGES

rule "Poster achievement":
    @Event eachPlayer
    @Condition len(eventPlayer.postersFound) == 12

    bigMessage(eventPlayer, "Achievement get! Most wanted: find all the posters of you")
    eventPlayer.achievements.append(Achievement.MOST_WANTED)
    manageAchievements()

rule "Inner lights reset":
    @Event eachPlayer
    @Condition distance(eventPlayer.getEyePosition(), vect(-111.73, 14.04, -137.34)) > 4 and not eventPlayer.powerSwitched

    if eventPlayer not in powerPanelPlayers[0]:
        powerPanelPlayers[0].append(eventPlayer)
    if eventPlayer not in powerPanelPlayers[1]:
        powerPanelPlayers[1].append(eventPlayer)
    if eventPlayer not in powerPanelPlayers[2]:
        powerPanelPlayers[2].append(eventPlayer)
    if eventPlayer not in powerPanelPlayers[3]:
        powerPanelPlayers[3].append(eventPlayer)
    if eventPlayer not in powerPanelPlayers[4]:
        powerPanelPlayers[4].append(eventPlayer)

rule "Lights on check":
    @Event eachPlayer
    @Condition eventPlayer.wiresConnected and eventPlayer.generatorOn and eventPlayer.powerSwitched

    eventPlayer.lightsOn = true
    playersInDark.remove(eventPlayer)
    playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATING_SOUND, null, eventPlayer.getPosition() - eventPlayer.getFacingDirection() * 0.1, 100)
    INCREMENT_STATE(Id.innerSwitch1)
    INCREMENT_STATE(Id.innerSwitch2)
    INCREMENT_STATE(Id.innerSwitch3)
    INCREMENT_STATE(Id.innerSwitch4)
    INCREMENT_STATE(Id.innerSwitch5)

rule "Set inner power box state":
    @Event eachPlayer
    @Condition eventPlayer.wiresConnected and eventPlayer.generatorOn

    SET_STATE(Id.innerPowerBox, 3)
    wait(3)
    smallMessage(eventPlayer, "If you could just get the power panel all green, maybe the lights would turn on")

rule "Inner workbench minigame start":
    @Event eachPlayer
    @Condition eventPlayer.isDoingInnerMinigame

    createBeam(eventPlayer, Beam.GRAPPLE, updateEveryTick(INNER_MINIGAME_2D_TO_3D(vect(0.801, 0.451, 0))), updateEveryTick(INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(eventPlayer.innerMinigameValue1) * 0.422, 0.451 + sin(eventPlayer.innerMinigameValue1 * 2) * 0.15, 0))), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    pushEffectDeleteQueue()

    createBeam(eventPlayer, Beam.BRIGITTE_FLAIL_CHAIN, updateEveryTick(INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(eventPlayer.innerMinigameValue1) * 0.422 + sin(eventPlayer.innerMinigameValue2) * 0.2, 0.451 + cos(eventPlayer.innerMinigameValue2) * 0.2 + sin(eventPlayer.innerMinigameValue1 * 2) * 0.15, 0))), updateEveryTick(INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(eventPlayer.innerMinigameValue1) * 0.422 + sin(eventPlayer.innerMinigameValue2 + 2 * PI / 3) * 0.2, 0.451 + cos(eventPlayer.innerMinigameValue2 + 2 * PI / 3) * 0.2 + sin(eventPlayer.innerMinigameValue1 * 2) * 0.15, 0))), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createBeam(eventPlayer, Beam.BRIGITTE_FLAIL_CHAIN, updateEveryTick(INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(eventPlayer.innerMinigameValue1) * 0.422 + sin(eventPlayer.innerMinigameValue2 + 2 * PI / 3) * 0.2, 0.451 + cos(eventPlayer.innerMinigameValue2 + 2 * PI / 3) * 0.2 + sin(eventPlayer.innerMinigameValue1 * 2) * 0.15, 0))), updateEveryTick(INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(eventPlayer.innerMinigameValue1) * 0.422 + sin(eventPlayer.innerMinigameValue2 + 4 * PI / 3) * 0.2, 0.451 + cos(eventPlayer.innerMinigameValue2 + 4 * PI / 3) * 0.2 + sin(eventPlayer.innerMinigameValue1 * 2) * 0.15, 0))), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createBeam(eventPlayer, Beam.BRIGITTE_FLAIL_CHAIN, updateEveryTick(INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(eventPlayer.innerMinigameValue1) * 0.422 + sin(eventPlayer.innerMinigameValue2 + 4 * PI / 3) * 0.2, 0.451 + cos(eventPlayer.innerMinigameValue2 + 4 * PI / 3) * 0.2 + sin(eventPlayer.innerMinigameValue1 * 2) * 0.15, 0))), updateEveryTick(INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(eventPlayer.innerMinigameValue1) * 0.422 + sin(eventPlayer.innerMinigameValue2) * 0.2, 0.451 + cos(eventPlayer.innerMinigameValue2) * 0.2 + sin(eventPlayer.innerMinigameValue1 * 2) * 0.15, 0))), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    pushEffectDeleteQueue()

rule "Stop inner workbench minigame controls":
    @Event eachPlayer
    @Condition eventPlayer.isDoingInnerMinigame and not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.isHoldingInnerMinigameControl1 = false
    eventPlayer.isHoldingInnerMinigameControl2 = false

    stopChasingVariable(eventPlayer.innerMinigameValue1)
    stopChasingVariable(eventPlayer.innerMinigameValue2)

rule "Inner workbench minigame success":
    @Event eachPlayer
    @Condition abs(eventPlayer.innerMinigameValue1 % (2 * PI) - 3 * PI / 2) < 0.1 and abs(eventPlayer.innerMinigameValue2 % (2 * PI / 3) - PI / 6) < 0.05

    eventPlayer.hasFinishedInnerMinigame = true
    stopChasingVariable(eventPlayer.innerMinigameValue1)
    stopChasingVariable(eventPlayer.innerMinigameValue2)
    eventPlayer.innerMinigameValue1 = 3 * PI / 2
    eventPlayer.innerMinigameValue2 = PI / 6
    SET_STATE(Id.innerWorkbench, 1)
    eventPlayer.inventory.remove("Fiddly part")
    eventPlayer.inventory = "Reverse polarity fiddly part".concat(eventPlayer.inventory)
    smallMessage(eventPlayer, "You manage to reverse the polarity of the fiddly part")

rule "Inner workbench minigame stop":
    @Event eachPlayer
    @Condition eventPlayer.isDoingInnerMinigame and distance(eventPlayer, eventPlayer.innerWorkbench[Item.POINT]) > 3

    innerMinigamePlayers.remove(eventPlayer)
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    innerMinigameInitialState()

rule "Outer workbench minigame start":
    @Event eachPlayer
    @Condition eventPlayer.isDoingOuterMinigame

    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[1]], OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17 * 3, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[2]], OUTER_MINIGAME_2D_TO_3D(vect(0.62, 0.08 + 0.17 * 2, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[3]], OUTER_MINIGAME_2D_TO_3D(vect(0.82, 0.08 + 0.17 * 2, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[4]], OUTER_MINIGAME_2D_TO_3D(vect(0.52, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[5]], OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[6]], OUTER_MINIGAME_2D_TO_3D(vect(0.92, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[7]], OUTER_MINIGAME_2D_TO_3D(vect(0.42, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[8]], OUTER_MINIGAME_2D_TO_3D(vect(0.62, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[9]], OUTER_MINIGAME_2D_TO_3D(vect(0.82, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, outerMinigameColors[eventPlayer.outerMinigameState[10]], OUTER_MINIGAME_2D_TO_3D(vect(1.02, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, EffectReeval.COLOR)
    pushEffectDeleteQueue()

rule "Outer workbench minigame success":
    @Event eachPlayer
    @Condition all([e == 1 for e in eventPlayer.outerMinigameState])

    eventPlayer.hasFinishedOuterMinigame = true
    SET_STATE(Id.outerWorkbench, 1)
    eventPlayer.inventory.remove("Red battery")
    eventPlayer.inventory = "Black painted battery".concat(eventPlayer.inventory)
    smallMessage(eventPlayer, "You manage to change the color of the battery")

    if eventPlayer.outerMinigameMovesMade <= 5:
        wait(3) # wait for small message to disappear
        bigMessage(eventPlayer, "Achievement get! Puzzle master: solve the color puzzle in 5 moves")
        eventPlayer.achievements.append(Achievement.PUZZLE_MASTER)
        manageAchievements()

rule "Outer workbench minigame stop":
    @Event eachPlayer
    @Condition eventPlayer.isDoingOuterMinigame and distance(eventPlayer, eventPlayer.outerWorkbench[Item.POINT]) > 3

    outerMinigamePlayers.remove(eventPlayer)
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    wait(RACE_CONDITION_DELAY) # prevents flashes
    outerMinigameInitialState()

rule "Barn workbench minigame start":
    @Event eachPlayer
    @Condition eventPlayer.isDoingBarnMinigame

    createEffect(eventPlayer, Effect.SPHERE, Color.BLACK, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[eventPlayer.barnMinigamePosState[0]]), 0.05, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, Color.BLACK, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[eventPlayer.barnMinigamePosState[1]]), 0.05, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, Color.BLACK, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[eventPlayer.barnMinigamePosState[2]]), 0.05, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, Color.BLACK, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[eventPlayer.barnMinigamePosState[3]]), 0.05, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, Color.BLUE, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[eventPlayer.barnMinigamePosState[4]]), 0.05, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, Color.BLUE, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[eventPlayer.barnMinigamePosState[5]]), 0.05, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, Color.BLUE, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[eventPlayer.barnMinigamePosState[6]]), 0.05, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()
    createEffect(eventPlayer, Effect.SPHERE, Color.BLUE, BARN_MINIGAME_2D_TO_3D(barnMinigamePoints[eventPlayer.barnMinigamePosState[7]]), 0.05, EffectReeval.POSITION_AND_RADIUS)
    pushEffectDeleteQueue()

rule "Barn workbench minigame success":
    @Event eachPlayer
    @Condition all([[0, 2, 2, 2, 2, 1, 1, 1, 1][index] == e for e, index in eventPlayer.barnMinigameColorState])

    eventPlayer.hasFinishedBarnMinigame = true
    SET_STATE(Id.barnWorkbench, 1)
    eventPlayer.inventory.remove("Right handed remote")
    eventPlayer.inventory = "Left handed remote".concat(eventPlayer.inventory)
    smallMessage(eventPlayer, "You pick up the remote with your left hand. Turns out remotes aren't handed.")

rule "Barn workbench minigame stop":
    @Event eachPlayer
    @Condition eventPlayer.isDoingBarnMinigame and distance(eventPlayer, eventPlayer.barnWorkbench[Item.POINT]) > 3

    barnMinigamePlayers.remove(eventPlayer)
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    wait(RACE_CONDITION_DELAY) # prevents flashes
    barnMinigameInitialState()

# Can go outside
rule "Can go outside check":
    @Event eachPlayer
    @Condition eventPlayer.hasSunglasses
    @Condition eventPlayer.hasSunscreen

    eventPlayer.canGoOutside = true

# Bruce wings fix
rule "Bruce wings fix":
    @Event eachPlayer
    @Condition eventPlayer.bruceTimer == 60

    SET_STATE(Id.outerBruce, 9)
    stopChasingVariable(eventPlayer.bruceTimer)

# In a hurry achievement
rule "In a hurry achievement":
    @Event eachPlayer
    @Condition eventPlayer.timesBruceClicked == 60

    bigMessage(eventPlayer, "Achievement get! In a hurry: pester Bruce 60 times")
    eventPlayer.achievements.append(Achievement.IN_A_HURRY)
    manageAchievements()



# CONTROLS

rule "Switch between heroes":
    @Event eachPlayer
    @Condition eventPlayer.canBeTheOtherGuy
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and not eventPlayer.pauseInteraction

    if eventPlayer.isJunk:
        eventPlayer.isJunk = false
        smallMessage(eventPlayer, "You are now the other guy")
        wait(RACE_CONDITION_DELAY)
        eventPlayer.junkInventory = eventPlayer.inventory
        eventPlayer.inventory = eventPlayer.hogInventory
        eventPlayer.junkEquipped = eventPlayer.equipped
        eventPlayer.equipped = eventPlayer.hogEquipped
        eventPlayer.startForcingHero(Hero.ROADHOG)
        eventPlayer.teleport(eventPlayer.hogPos)
        eventPlayer.setFacing(eventPlayer.hogFacing, Relativity.TO_WORLD)
        eventPlayer.isHog = true
        eventPlayer.preloadHero(Hero.ROADHOG)
    else:
        eventPlayer.isHog = false
        smallMessage(eventPlayer, "You stop being the other guy")
        wait(RACE_CONDITION_DELAY)
        eventPlayer.hogInventory = eventPlayer.inventory
        eventPlayer.inventory = eventPlayer.junkInventory
        eventPlayer.hogEquipped = eventPlayer.equipped
        eventPlayer.equipped = eventPlayer.junkEquipped
        eventPlayer.startForcingHero(Hero.JUNKRAT)
        eventPlayer.teleport(eventPlayer.junkPos)
        eventPlayer.setFacing(eventPlayer.junkFacing, Relativity.TO_WORLD)
        eventPlayer.isJunk = true
        eventPlayer.preloadHero(Hero.JUNKRAT)

    popAllTextDeleteQueue()
    manageEquips()

rule "Scroll inventory forwards":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) and not eventPlayer.pauseInteraction

    if len(eventPlayer.inventory) > 1:
        eventPlayer.inventory.append(eventPlayer.inventory[0])
        del eventPlayer.inventory[0]

rule "Scroll inventory backwards":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) and not eventPlayer.pauseInteraction

    if len(eventPlayer.inventory) > 1:
        eventPlayer.inventory = eventPlayer.inventory.last().concat(eventPlayer.inventory.slice(0, len(eventPlayer.inventory) - 1))

# Interact
def playGetItem():
    playEffect(eventPlayer, DynamicEffect.SOLDIER_SPRINT_START_SOUND, null, eventPlayer, 100)
    playEffect(eventPlayer, DynamicEffect.SOLDIER_SPRINT_START_SOUND, null, eventPlayer, 100)

def playNoItem():
    playEffect(eventPlayer, DynamicEffect.DVA_MICRO_MISSILES_EXPLOSION_SOUND, null, eventPlayer.getPosition() + eventPlayer.getFacingDirection(), 40)

#!define NOTHING_LEFT_MESSAGE "There's nothing left in there"

#!define SHOULD_INTERACT(item) (distance(eventPlayer.getEyePosition(), item[Item.POINT]) < INTERACT_DISTANCE and \
distance(item[Item.POINT], eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * distance(eventPlayer.getEyePosition(), item[Item.POINT])) < (item[Item.RADIUS]) and \
(not item[Item.NEEDS_LOS] or isInLoS(item[Item.POINT], eventPlayer.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS)))

rule "Interact":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and not eventPlayer.pauseInteraction

    eventPlayer.tValue = [elem for elem in eventPlayer.itemPoints if SHOULD_INTERACT(elem)]

    if len(eventPlayer.tValue) == 0:
        return

    eventPlayer.tValue = eventPlayer.tValue[0]

    if eventPlayer.tValue[Item.REMOVE_ON_STATE] > 0 and eventPlayer.tValue[Item.STATE] >= eventPlayer.tValue[Item.REMOVE_ON_STATE]:
        return

    eventPlayer.tIndex = eventPlayer.itemIds.index(eventPlayer.tValue[Item.ID])

    if eventPlayer.tValue[Item.STATE] < len(eventPlayer.tValue[Item.MESSAGE]):
        eventPlayer.tText = eventPlayer.tValue[Item.MESSAGE][eventPlayer.tValue[Item.STATE]]
        if eventPlayer.tText:
            smallMessage(eventPlayer, eventPlayer.tText)

        if eventPlayer.tValue[Item.ITEM_NAME]:
            if eventPlayer.tValue[Item.PLAY_GET_SOUND]:
                playGetItem()
            GIVE_ITEM(eventPlayer.tValue[Item.ITEM_NAME])
            eventPlayer.tValue[Item.STATE]++
            eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
        else:
            if eventPlayer.tValue[Item.PLAY_GET_SOUND]:
                playNoItem()
    elif eventPlayer.tValue[Item.PLAY_GET_SOUND]:
        playNoItem()
        smallMessage(eventPlayer, NOTHING_LEFT_MESSAGE)

    # special interactions

    if eventPlayer.isJunk:
        if eventPlayer.wiresConnected and eventPlayer.generatorOn and not eventPlayer.lightsOn:
            if eventPlayer.tValue[Item.ID] == Id.innerSwitch1:
                TOGGLE_POWER_SWITCH(4)
                TOGGLE_POWER_SWITCH(0)
                TOGGLE_POWER_SWITCH(1)
                makeSwitchNoise()
                checkPowerPanel()
            elif eventPlayer.tValue[Item.ID] == Id.innerSwitch2:
                TOGGLE_POWER_SWITCH(0)
                TOGGLE_POWER_SWITCH(1)
                TOGGLE_POWER_SWITCH(2)
                makeSwitchNoise()
                checkPowerPanel()
            elif eventPlayer.tValue[Item.ID] == Id.innerSwitch3:
                TOGGLE_POWER_SWITCH(1)
                TOGGLE_POWER_SWITCH(2)
                TOGGLE_POWER_SWITCH(3)
                makeSwitchNoise()
                checkPowerPanel()
            elif eventPlayer.tValue[Item.ID] == Id.innerSwitch4:
                TOGGLE_POWER_SWITCH(2)
                TOGGLE_POWER_SWITCH(3)
                TOGGLE_POWER_SWITCH(4)
                makeSwitchNoise()
                checkPowerPanel()
            elif eventPlayer.tValue[Item.ID] == Id.innerSwitch5:
                TOGGLE_POWER_SWITCH(3)
                TOGGLE_POWER_SWITCH(4)
                TOGGLE_POWER_SWITCH(0)
                makeSwitchNoise()
                checkPowerPanel()

        if eventPlayer.tValue[Item.ID] == Id.tutSafe2:
            tutorialTextPlayers[TutorialText.INTERACT].remove(eventPlayer)
            eventPlayer.molePersonRiddleLine = 0
        elif eventPlayer.tValue[Item.ID] == Id.tutSafe5:
            if eventPlayer.tValue[Item.STATE] == 0:
                tutorialTextPlayers[TutorialText.INTERACT].remove(eventPlayer)
                tutorialTextPlayers[TutorialText.INV_CYCLE].append(eventPlayer)
                tutorialTextPlayers[TutorialText.APPLY_ITEM].append(eventPlayer)
                eventPlayer.inventory.append("Rusty key")
                eventPlayer.tValue[Item.STATE]++
                eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
        elif eventPlayer.tValue[Item.ID] == Id.innerPowerBox:
            if not eventPlayer.wiresConnected or not eventPlayer.generatorOn:
                if eventPlayer.tValue[Item.STATE] < 2:
                    eventPlayer.tValue[Item.STATE]++
                    eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
            elif not eventPlayer.powerSwitched:
                smallMessage(eventPlayer, "There's power, so the switches next to these red lights should work")
            else:
                smallMessage(eventPlayer, "The pretty green lights make you giddy")
        elif eventPlayer.tValue[Item.ID] == Id.innerGenerator:
            if eventPlayer.tValue[Item.STATE] == 0:
                eventPlayer.tValue[Item.STATE]++
                eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
        elif eventPlayer.tValue[Item.ID] == Id.innerRadio:
            eventPlayer.hasFoundInnerRadio = true
        elif eventPlayer.tValue[Item.ID] == Id.innerWorkbench and not eventPlayer.isDoingInnerMinigame:
            if eventPlayer.tValue[Item.STATE] == 0:
                smallMessage(eventPlayer, "The workbench has a label that says \"polarity reversificator\" on it")
            else:
                smallMessage(eventPlayer, "The workbench has outlived its usefulness")
        elif eventPlayer.tValue[Item.ID] == Id.innerMinigameControl1 and eventPlayer.isDoingInnerMinigame and not eventPlayer.hasFinishedInnerMinigame:
            eventPlayer.isHoldingInnerMinigameControl1 = true
            chase(eventPlayer.innerMinigameValue1, INF, rate=1, ChaseReeval.NONE)
            chase(eventPlayer.innerMinigameValue2, INF, rate=1.8, ChaseReeval.NONE)
        elif eventPlayer.tValue[Item.ID] == Id.innerMinigameControl2 and eventPlayer.isDoingInnerMinigame and not eventPlayer.hasFinishedInnerMinigame:
            eventPlayer.isHoldingInnerMinigameControl2 = true
            chase(eventPlayer.innerMinigameValue1, INF, rate=1.8, ChaseReeval.NONE)
            chase(eventPlayer.innerMinigameValue2, INF, rate=1, ChaseReeval.NONE)
        elif eventPlayer.tValue[Item.ID] == Id.innerMinigameSkip and eventPlayer.isDoingInnerMinigame and not eventPlayer.hasFinishedInnerMinigame:
            eventPlayer.innerMinigameValue1 = 3 * PI / 2
            eventPlayer.innerMinigameValue2 = PI / 6
        elif eventPlayer.tValue[Item.ID] == Id.innerSunglasses:
            if Equip.SUNGLASES not in eventPlayer.equipped:
                INCREMENT_STATE(Id.innerSunglasses)
                eventPlayer.hasSunglasses = true
                eventPlayer.equipped.append(Equip.SUNGLASES)
                manageEquips()
                if not eventPlayer.outsideMapFound:
                    wait(3) # wait for small message to disappear
                    bigMessage(eventPlayer, "Achievement get! Infrasight: find the sunglasses without using the map")
                    eventPlayer.achievements.append(Achievement.INFRASIGHT)
                    manageAchievements()
        elif eventPlayer.tValue[Item.STATE] == 0 and (eventPlayer.tValue[Item.ID] == Id.innerValve1 or eventPlayer.tValue[Item.ID] == Id.innerValve2 or eventPlayer.tValue[Item.ID] == Id.innerValve3):
            eventPlayer.tValue[Item.STATE]++
            eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
            eventPlayer.numVentsClosed++
            playEffect(eventPlayer, DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, null, eventPlayer.tValue[Item.POINT], 100)
            if eventPlayer.numVentsClosed == 1:
                smallMessage(eventPlayer, "You twist the valve shut and hear the airflow decrease")
            elif eventPlayer.numVentsClosed == 2:
                smallMessage(eventPlayer, "You twist the valve shut and hear the airflow slow to a trickle")
            else:
                smallMessage(eventPlayer, "You twist the valve shut and hear the air stop entirely")
        elif eventPlayer.tValue[Item.ID] == Id.innerVent3:
            if eventPlayer.tValue[Item.STATE] == 0:
                if eventPlayer.numVentsClosed == 3:
                    eventPlayer.tValue[Item.STATE]++
                    eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
                    smallMessage(eventPlayer, "You carefully reach your hand in and extract a dusty key")
                    GIVE_ITEM("Vent key")
                else:
                    smallMessage(eventPlayer, "There's something in the back, but the blades are spinning too fast to grab it")
            else:
                smallMessage(eventPlayer, NOTHING_LEFT_MESSAGE)
        elif eventPlayer.tValue[Item.ID] == Id.outerBruce:
            if eventPlayer.tValue[Item.STATE] == 0:
                CREATE_TEXT("You want me to help you? I don't even know who you are.", BRUCE_TEXT_LOCATION)
            elif eventPlayer.tValue[Item.STATE] == 1:
                CREATE_TEXT("Alright, since you're a friend of Roadhog, I guess I can help you out.\nI'll need you to bring me three things though:\n- a black battery\n- some purified water\n- and a bottle of strong alcohol.", BRUCE_TEXT_LOCATION)
            elif eventPlayer.tValue[Item.STATE] < 8:
                eventPlayer.tText = "You still need to bring me:"
                if eventPlayer.tValue[Item.STATE] % 2 == 1:
                    eventPlayer.tText = "{0}\n- a black battery".format(eventPlayer.tText)
                if (eventPlayer.tValue[Item.STATE] - 1) % 4 < 2:
                    eventPlayer.tText = "{0}\n- some purified water".format(eventPlayer.tText)
                if eventPlayer.tValue[Item.STATE] <= 4:
                    eventPlayer.tText = "{0}\n- a bottle of strong alcohol".format(eventPlayer.tText)
                CREATE_TEXT(eventPlayer.tText, BRUCE_TEXT_LOCATION)
            elif eventPlayer.tValue[Item.STATE] == 8:
                CREATE_TEXT("Don't be impatient, it's only been {0} seconds".format(floor(eventPlayer.bruceTimer)), BRUCE_TEXT_LOCATION)
                eventPlayer.timesBruceClicked++
            elif eventPlayer.tValue[Item.STATE] == 9:
                if Equip.WINGS not in eventPlayer.equipped:
                    CREATE_TEXT("Alright, the wings are done. You're going to have to find a high place to use\nthem though. I've heard there are secret tunnels that lead up to the dome. The\nbartender might know more.", BRUCE_TEXT_LOCATION)
                    eventPlayer.equipped.append(Equip.WINGS)
                    manageEquips()
                else:
                    CREATE_TEXT("You're going to have to find a high place to use your wings. I've heard there\nare secret tunnels that lead up to the dome. The bartender might know more.", BRUCE_TEXT_LOCATION)
                SET_STATE(Id.outerBartender, 2)
        elif eventPlayer.tValue[Item.ID] == Id.outerSmuggler:
            if not eventPlayer.canUtilizeSmuggler:
                CREATE_TEXT("Welcome to Tracer's Delivery Service!\nWe deliver anything to anyone anywhere!\nAnd we'll even deliver stuff from others to you!\nLifetime membership is only {0} dollars!".format(SMUGGLER_COST), INSIDE_SMUGGLER_TEXT_LOCATION)
            else:
                if eventPlayer.insideSmugglerItem:
                    insideMailTextPlayers.remove(eventPlayer)
                    CREATE_TEXT("Looks like we have something for you!", INSIDE_SMUGGLER_TEXT_LOCATION)
                    eventPlayer.tText = eventPlayer.insideSmugglerItem
                    smallMessage(eventPlayer, "Received {0}".format(eventPlayer.tText))
                    GIVE_ITEM(eventPlayer.insideSmugglerItem)
                    eventPlayer.insideSmugglerItem = null
                else:
                    CREATE_TEXT("Sorry, nothing for you", INSIDE_SMUGGLER_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == Id.outerBartender:
            if eventPlayer.tValue[Item.STATE] == 0:
                CREATE_TEXT("Drinks round here cost {0} bucks. But just for you,\nI'll make an exception and only charge ya {1}.".format(ALCOHOL_COST / 2, ALCOHOL_COST), BARTENDER_TEXT_LOCATION)
            elif eventPlayer.tValue[Item.STATE] == 1:
                CREATE_TEXT("You've cleaned me right out of liquor.", BARTENDER_TEXT_LOCATION)
            else:
                CREATE_TEXT("So you're looking for the mole people, huh. I've heard they can be found in the\nrooms above the Chinese place. They all tend to talk in riddles though.", BARTENDER_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == Id.outerNotSmuggler:
            if eventPlayer.tValue[Item.STATE] == 0:
                CREATE_TEXT("Hey, I'm looking for someone to embarrass themselves on stage,\nand you look like someone who doesn't know what that word means.\n\nGo up to the mic and do something silly, I'll pay you in cash.", NOT_SMUGGLER_TEXT_LOCATION)
                SET_STATE(Id.outerMic, 1)
            elif eventPlayer.tValue[Item.STATE] == 1:
                CREATE_TEXT("Alright, you've earned your pay.", NOT_SMUGGLER_TEXT_LOCATION)
                GIVE_ITEM("{0} dollars".format(ALCOHOL_COST + SMUGGLER_COST))
                eventPlayer.money = ALCOHOL_COST + SMUGGLER_COST
                eventPlayer.tValue[Item.STATE]++
                SAVE_STATE(eventPlayer.tValue)
            else:
                CREATE_TEXT("Did you know there's legends of a hidden race in Junkertown?\nSome say they go around stealing small objects, hiding things in vents.\nEh- but it's probably nothing right?", NOT_SMUGGLER_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == Id.outerToolbox1:
            if eventPlayer.tValue[Item.STATE] == 0:
                eventPlayer.equipped.append(Equip.DISGUISE)
                eventPlayer.tValue[Item.STATE]++
                SAVE_STATE(eventPlayer.tValue)
                manageEquips()
        elif eventPlayer.tValue[Item.ID] == Id.outerWorkbench and not eventPlayer.isDoingOuterMinigame:
            if eventPlayer.tValue[Item.STATE] == 0:
                smallMessage(eventPlayer, "The workbench has a number of paints left on it")
            else:
                smallMessage(eventPlayer, "The workbench has outlived its usefulness")
        elif Id.outerMinigameDot1 <= eventPlayer.tValue[Item.ID] and eventPlayer.tValue[Item.ID] <= Id.outerMinigameSkip and eventPlayer.isDoingOuterMinigame and not eventPlayer.hasFinishedOuterMinigame:
            eventPlayer.outerMinigameMovesMade++
            if eventPlayer.tValue[Item.ID] == Id.outerMinigameDot1:
                OUTER_MINIGAME_TOGGLE(1)
                OUTER_MINIGAME_TOGGLE(2)
                OUTER_MINIGAME_TOGGLE(3)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot2:
                OUTER_MINIGAME_TOGGLE(1)
                OUTER_MINIGAME_TOGGLE(2)
                OUTER_MINIGAME_TOGGLE(3)
                OUTER_MINIGAME_TOGGLE(4)
                OUTER_MINIGAME_TOGGLE(5)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot3:
                OUTER_MINIGAME_TOGGLE(1)
                OUTER_MINIGAME_TOGGLE(2)
                OUTER_MINIGAME_TOGGLE(3)
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(6)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot4:
                OUTER_MINIGAME_TOGGLE(2)
                OUTER_MINIGAME_TOGGLE(4)
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(7)
                OUTER_MINIGAME_TOGGLE(8)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot5:
                playEffect(eventPlayer, DynamicEffect.EXPLOSION_SOUND, null, eventPlayer, 30)
                eventPlayer.outerMinigameMovesMade--
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot6:
                OUTER_MINIGAME_TOGGLE(3)
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(6)
                OUTER_MINIGAME_TOGGLE(9)
                OUTER_MINIGAME_TOGGLE(10)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot7:
                OUTER_MINIGAME_TOGGLE(4)
                OUTER_MINIGAME_TOGGLE(7)
                OUTER_MINIGAME_TOGGLE(8)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot8:
                OUTER_MINIGAME_TOGGLE(4)
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(7)
                OUTER_MINIGAME_TOGGLE(8)
                OUTER_MINIGAME_TOGGLE(9)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot9:
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(6)
                OUTER_MINIGAME_TOGGLE(8)
                OUTER_MINIGAME_TOGGLE(9)
                OUTER_MINIGAME_TOGGLE(10)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameDot10:
                OUTER_MINIGAME_TOGGLE(6)
                OUTER_MINIGAME_TOGGLE(9)
                OUTER_MINIGAME_TOGGLE(10)
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameRotate1:
                eventPlayer.tMinigame = eventPlayer.outerMinigameState[1]
                eventPlayer.outerMinigameState[1] = eventPlayer.outerMinigameState[2]
                eventPlayer.outerMinigameState[2] = eventPlayer.outerMinigameState[3]
                eventPlayer.outerMinigameState[3] = eventPlayer.tMinigame
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameRotate2:
                eventPlayer.tMinigame = eventPlayer.outerMinigameState[4]
                eventPlayer.outerMinigameState[4] = eventPlayer.outerMinigameState[7]
                eventPlayer.outerMinigameState[7] = eventPlayer.outerMinigameState[8]
                eventPlayer.outerMinigameState[8] = eventPlayer.tMinigame
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameRotate3:
                eventPlayer.tMinigame = eventPlayer.outerMinigameState[6]
                eventPlayer.outerMinigameState[6] = eventPlayer.outerMinigameState[9]
                eventPlayer.outerMinigameState[9] = eventPlayer.outerMinigameState[10]
                eventPlayer.outerMinigameState[10] = eventPlayer.tMinigame
            elif eventPlayer.tValue[Item.ID] == Id.outerMinigameSkip:
                eventPlayer.outerMinigameState = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                eventPlayer.outerMinigameMovesMade = INF
            else:
                eventPlayer.outerMinigameMovesMade--
        elif eventPlayer.tValue[Item.ID] == Id.outerMic:
            if eventPlayer.tValue[Item.STATE] == 0:
                smallMessage(eventPlayer, "You don't know why you would waste any time on this")
            elif eventPlayer.tValue[Item.STATE] == 1:
                if Equip.DISGUISE in eventPlayer.equipped:
                    eventPlayer.tValue[Item.STATE]++
                    eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
                    SET_STATE(Id.outerNotSmuggler, 1)

                    eventPlayer.currentCutscene = Cutscene.COMEDY
                else:
                    smallMessage(eventPlayer, "You couldn't possible be silly without a hilarious costume")
            else:
                smallMessage(eventPlayer, "You're done with comedy for today")
        elif Id.outerDoor21 <= eventPlayer.tValue[Item.ID] and eventPlayer.tValue[Item.ID] <= Id.outerDoor25:
            printLog("{0} {1} {2}".format(Id.outerDoor21, Id.outerDoor25, eventPlayer.tValue[Item.ID]))
            if Equip.WINGS not in eventPlayer.equipped:
                CREATE_TEXT("You don't look like you're ready yet.\nCome back when you can soar.", eventPlayer.tValue[Item.POINT] + vect(0, 0.6, 0))
            else:
                if "Odd looking coin" in eventPlayer.inventory:
                    CREATE_COLORED_TEXT(moleLeaderRiddle[eventPlayer.molePersonRiddleLine], eventPlayer.tValue[Item.POINT] + vect(0, 0.6, 0), rgb(52, 152, 219))
                    eventPlayer.molePersonRiddleLine = (eventPlayer.molePersonRiddleLine + 1) % len(moleLeaderRiddle)
                elif eventPlayer.molePersonInteractStage == 0:
                    doMoleLeaderInteractionStage1()
                elif eventPlayer.molePersonInteractStage == 1:
                    doMoleLeaderInteractionStage2()
                elif eventPlayer.molePersonInteractStage == 2:
                    doMoleLeaderInteractionStage3()
                elif eventPlayer.molePersonInteractStage == 3:
                    doMoleLeaderInteractionStage4()
                elif eventPlayer.molePersonInteractStage == 4:
                    eventPlayer.currentCutscene = Cutscene.ENDING
                else:
                    CREATE_COLORED_TEXT(moleCoinRiddle[eventPlayer.molePersonRiddleLine], eventPlayer.tValue[Item.POINT] + vect(0, 0.6, 0), rgb(52, 152, 219))
                    eventPlayer.molePersonRiddleLine = (eventPlayer.molePersonRiddleLine + 1) % len(moleCoinRiddle)
        elif eventPlayer.tValue[Item.ID] == Id.outerBinoculars:
            freeze()
            hideUi()

            eventPlayer.startCamera(vect(-37.04, 14.25, -59.71) + vect(0.653, -0.107, 0.749) * 530, vect(-37.04, 14.25, -59.71) + vect(0.653, -0.107, 0.749) * 531, 0)
            wait(5)
            eventPlayer.stopCamera()

            if Achievement.MASTER_HACKER not in eventPlayer.achievements:
                bigMessage(eventPlayer, "Achievement get! Master hacker: glitch through the walls and enjoy the view")
                eventPlayer.achievements.append(Achievement.MASTER_HACKER)
                manageAchievements()

            unfreeze()
            showUi()

    if eventPlayer.isHog:
        if eventPlayer.tValue[Item.ID] == Id.barnSwitch1:
            eventPlayer.tPos = 10.656
            toggleBarnSwitch()
            ENTER_BARN_DIGIT(1)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == Id.barnSwitch2:
            eventPlayer.tPos = 10.581
            toggleBarnSwitch()
            ENTER_BARN_DIGIT(2)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == Id.barnSwitch3:
            eventPlayer.tPos = 10.509
            toggleBarnSwitch()
            ENTER_BARN_DIGIT(3)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == Id.barnSwitch4:
            eventPlayer.tPos = 10.425
            toggleBarnSwitch()
            ENTER_BARN_DIGIT(4)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == Id.barnSwitch5:
            eventPlayer.tPos = 10.346
            toggleBarnSwitch()
            ENTER_BARN_DIGIT(5)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == Id.barnPaperClue1:
            smallMessage(eventPlayer, "{0} {1} _ _ _".format(eventPlayer.barnCode[0], eventPlayer.barnCode[1]))
        elif eventPlayer.tValue[Item.ID] == Id.barnPaperClue2:
            smallMessage(eventPlayer, "_ _ _ {0} {1}".format(eventPlayer.barnCode[3], eventPlayer.barnCode[4]))
        elif eventPlayer.tValue[Item.ID] == Id.barnBike:
            smallMessage(eventPlayer, "There's some numbers scratched in the paint, but you can only make out the middle digit: {0}".format(eventPlayer.barnCode[2]))
        elif eventPlayer.tValue[Item.ID] == Id.barnSafe2:
            if Equip.LITTLE_BUDDY in eventPlayer.equipped:
                smallMessage(eventPlayer, "You've already secured your little buddy")
            else:
                eventPlayer.equipped.append(Equip.LITTLE_BUDDY)
                manageEquips()
                eventPlayer.tValue[Item.STATE]++
                eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
            eventPlayer.canLeaveBarn = true
        elif eventPlayer.tValue[Item.ID] == Id.barnWorkbench and not eventPlayer.isDoingBarnMinigame:
            if eventPlayer.tValue[Item.STATE] == 0:
                smallMessage(eventPlayer, "The workbench features a prominently placed mirror")
            else:
                smallMessage(eventPlayer, "The workbench has outlived its usefulness")
        elif Id.barnMinigameDot0 <= eventPlayer.tValue[Item.ID] and eventPlayer.tValue[Item.ID] <= Id.barnMinigameSkip and eventPlayer.isDoingBarnMinigame and not eventPlayer.hasFinishedBarnMinigame:
            if eventPlayer.tValue[Item.ID] == Id.barnMinigameDot0:
                eventPlayer.tPos = 0
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameDot1:
                eventPlayer.tPos = 1
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameDot2:
                eventPlayer.tPos = 2
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameDot3:
                eventPlayer.tPos = 3
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameDot4:
                eventPlayer.tPos = 4
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameDot5:
                eventPlayer.tPos = 5
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameDot6:
                eventPlayer.tPos = 6
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameDot7:
                eventPlayer.tPos = 7
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameDot8:
                eventPlayer.tPos = 8
                barnMinigameClick()
            elif eventPlayer.tValue[Item.ID] == Id.barnMinigameSkip:
                eventPlayer.barnMinigameColorState = [0, 2, 2, 2, 2, 1, 1, 1, 1]
                eventPlayer.barnMinigamePosState = [5, 6, 7, 8, 1, 2, 3, 4]
        elif eventPlayer.tValue[Item.ID] == Id.outsideFridge1:
            eventPlayer.outsideMapFound = true
            freeze()
            hideUi()
            mapMarkerPlayers.append(eventPlayer)
            eventPlayer.startCamera(vect(-81.29, 50.24, -143.14), vect(-81.29, 50.24, -143.14) + vect(-0.00682, -0.9994, -0.03402), 0)
            wait(0.5)
            mapMarkerPlayers.remove(eventPlayer)
            wait(0.5)
            mapMarkerPlayers.append(eventPlayer)
            wait(0.5)
            mapMarkerPlayers.remove(eventPlayer)
            wait(0.5)
            mapMarkerPlayers.append(eventPlayer)
            wait(0.5)
            mapMarkerPlayers.remove(eventPlayer)
            wait(0.5)
            mapMarkerPlayers.append(eventPlayer)
            wait(0.5)
            mapMarkerPlayers.remove(eventPlayer)
            wait(0.5)
            mapMarkerPlayers.append(eventPlayer)
            wait(0.5)
            mapMarkerPlayers.remove(eventPlayer)
            eventPlayer.stopCamera()
            showUi()
            unfreeze()
        elif eventPlayer.tValue[Item.ID] == Id.outsideSmuggler:
            if not eventPlayer.canUtilizeSmuggler:
                CREATE_TEXT("Welcome to Tracer's Delivery Service!\nWe deliver anything to anyone anywhere!\nAnd we'll even deliver stuff from others to you!\nLifetime membership is only {0} dollars!".format(SMUGGLER_COST), OUTSIDE_SMUGGLER_TEXT_LOCATION)
            else:
                if eventPlayer.outsideSmugglerItem:
                    outsideMailTextPlayers.remove(eventPlayer)
                    CREATE_TEXT("Looks like we have something for you!", OUTSIDE_SMUGGLER_TEXT_LOCATION)
                    eventPlayer.tText = eventPlayer.outsideSmugglerItem
                    smallMessage(eventPlayer, "Received {0}".format(eventPlayer.tText))
                    GIVE_ITEM(eventPlayer.outsideSmugglerItem)
                    eventPlayer.outsideSmugglerItem = null
                else:
                    CREATE_TEXT("Sorry, nothing for you", OUTSIDE_SMUGGLER_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == Id.outsideMolePersonRoom:
            if eventPlayer.molePersonInteractStage == 0:
                CREATE_TEXT("No one here but us mole peo- er, coconuts.", MOLE_PERSON_ROOM_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == Id.outsideMolePersonOuthouse:
            if eventPlayer.molePersonInteractStage == 1:
                CREATE_TEXT("Uhh, \"cacaw! cacaw!\"", MOLE_PERSON_OUTHOUSE_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == Id.outsideMolePersonCar:
            if eventPlayer.molePersonInteractStage == 2:
                CREATE_TEXT("Vroom vroom, just a normal car here.", MOLE_PERSON_CAR_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == Id.outsideMolePersonCliff:
            if eventPlayer.molePersonInteractStage == 3:
                CREATE_TEXT("*Intense silence*", MOLE_PERSON_CLIFF_TEXT_LOCATION)

    if (Id.outerPoster1 <= eventPlayer.tValue[Item.ID] and eventPlayer.tValue[Item.ID] <= Id.outerPoster10) or eventPlayer.tValue[Item.ID] == Id.outsidePoster1 or eventPlayer.tValue[Item.ID] == Id.outsidePoster2:
        if eventPlayer.tValue[Item.ID] not in eventPlayer.postersFound:
            eventPlayer.postersFound.append(eventPlayer.tValue[Item.ID])

rule "Restart game":
    @Event eachPlayer
    @Condition eventPlayer.hasFinishedGame and eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.isOnSecondRun = true
    resetGame()



# Apply
#!define CANT_APPLY_MESSAGE random.choice(["You can't use that thing with this thing", "You can't use that thing with this thing", "You can't use that thing with this thing", \
"It would be disasterous to use those two things together", "Trying to use those together would be unmitigated poppycock", "Are you just trying every possible combination?", \
"Some things were not meant to mix. Specifically these two.", "Only an amateur would use that in this way, which you are not", "You contemplate trying to force these things together, but decide against it", \
"To join these two would be a most unholy matrimony", "You're as willing as the next man to perform an experiment, but not this one"])
#!define NO_ITEM_MESSAGE random.choice(["You don't have anything to use", "You don't have anything to use", "You don't have anything to use", \
"Your hands are empty", "Your hands are empty", "Your hands are empty", "You try punching it, but nothing happens"])

#!define SHOULD_APPLY_ITEM(entry) (entry[Item.STATE] < len(entry[Item.REQUIRED_ITEM]) and eventPlayer.inventory[0] == entry[Item.REQUIRED_ITEM][entry[Item.STATE]])

# have to save to a variable due to race conditions when immediately changing the state after showing the message
#!define APPLY_ITEM_SUCCESS(item) eventPlayer.tText = item[Item.SUCCESS_MESSAGE][item[Item.STATE]] \
smallMessage(eventPlayer, eventPlayer.tText)
def APPLY_ITEM_FAIL():
    if len(eventPlayer.inventory) == 0:
        smallMessage(eventPlayer, NO_ITEM_MESSAGE)
    else:
        smallMessage(eventPlayer, CANT_APPLY_MESSAGE)

rule "Apply":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and not eventPlayer.pauseInteraction

    if SHOULD_INTERACT(eventPlayer.tutGate1) or SHOULD_INTERACT(eventPlayer.tutGate2):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.tutGate1)
        if eventPlayer.tValue[Item.STATE] == 0:
            if SHOULD_APPLY_ITEM(eventPlayer.tValue):
                APPLY_ITEM_SUCCESS(eventPlayer.tValue)
                eventPlayer.tValue[Item.STATE]++
                SAVE_STATE(eventPlayer.tValue)
                INCREMENT_STATE(Id.tutGate2)

                del eventPlayer.inventory[0]
                playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, null, eventPlayer, 30)
                eventPlayer.tutorialFinished = true
                playersInDark.append(eventPlayer)
                tutorialTextPlayers[TutorialText.INV_CYCLE].remove(eventPlayer)
                tutorialTextPlayers[TutorialText.APPLY_ITEM].remove(eventPlayer)
                tutorialTextPlayers[TutorialText.HINTS].append(eventPlayer)
            else:
                APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerWires):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.innerWires)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)

            innerWirePlayers.append(eventPlayer)
            eventPlayer.wiresConnected = true
            del eventPlayer.inventory[0]
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerBarrel2):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.innerBarrel2)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)

            del eventPlayer.inventory[0]
            GIVE_ITEM("Fuel filled petrol can")
            createEffect(eventPlayer, Effect.MOIRA_ORB_HEAL_SOUND, null, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            pushEffectDeleteQueue()
            wait(2)
            popEffectDeleteQueue()
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerGenerator):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.innerGenerator)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE] = 2
            SAVE_STATE(eventPlayer.tValue)

            del eventPlayer.inventory[0]
            GIVE_ITEM("Empty petrol can")
            createEffect(eventPlayer, Effect.MOIRA_ORB_HEAL_SOUND, null, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            pushEffectDeleteQueue()
            wait(2)
            popEffectDeleteQueue()
            eventPlayer.generatorOn = true
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerWorkbench):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.innerWorkbench)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.isDoingInnerMinigame = true
            innerMinigamePlayers.append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerRadio):
        eventPlayer.hasFoundInnerRadio = true
        if eventPlayer.inventory[0] == "Fiddly part":
            smallMessage(eventPlayer, "You need a reverse polarity fiddly part to work with Australian radios.\n                        Maybe you can switch this one at a workbench")
        elif eventPlayer.inventory[0] == "Reverse polarity fiddly part":
            eventPlayer.inventory.remove("Reverse polarity fiddly part")
            INCREMENT_STATE(Id.innerRadio)
            eventPlayer.currentCutscene = Cutscene.INNER_RADIO
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerToolbox2):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.innerToolbox2)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)

            eventPlayer.hasSunscreen = true
            eventPlayer.equipped.append(Equip.SUNSCREEN)
            manageEquips()
            del eventPlayer.inventory[0]
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outerBruce):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.outerBruce)
        if eventPlayer.tValue[Item.STATE] == 0 or eventPlayer.tValue[Item.STATE] > 8:
            if strContains(eventPlayer.inventory[0], "dollars"):
                CREATE_TEXT("I don't take bribes, son.", BRUCE_TEXT_LOCATION)
            else:
                CREATE_TEXT("I have enough junk in here without that cluttering the place up.", BRUCE_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.STATE] < 8:
            if eventPlayer.inventory[0] == "Black painted battery":
                del eventPlayer.inventory[0]
                CREATE_TEXT("Hmph, I guess this will have to do.", BRUCE_TEXT_LOCATION)
                eventPlayer.tValue[Item.STATE]++
            elif eventPlayer.inventory[0] == "Water filled petrol can":
                del eventPlayer.inventory[0]
                CREATE_TEXT("Are you sure this water is pure?", BRUCE_TEXT_LOCATION)
                eventPlayer.tValue[Item.STATE] += 2
            elif eventPlayer.inventory[0] == "Strong alcohol":
                del eventPlayer.inventory[0]
                CREATE_TEXT("Ah, this is the stuff.", BRUCE_TEXT_LOCATION)
                eventPlayer.tValue[Item.STATE] += 4
            elif eventPlayer.inventory[0] == "Red battery":
                CREATE_TEXT("Weren't you listening? I need a black battery.", BRUCE_TEXT_LOCATION)
            else:
                CREATE_TEXT("What is this? I don't need it.", BRUCE_TEXT_LOCATION)
            SAVE_STATE(eventPlayer.tValue)

            if eventPlayer.tValue[Item.STATE] == 8:
                CREATE_TEXT("Alright, that's all the items. Give me a minute and I'll have\nthe wings ready for you.", BRUCE_TEXT_LOCATION)
                chase(eventPlayer.bruceTimer, 60, duration=60, ChaseReeval.NONE)
        elif eventPlayer.tValue[Item.STATE] == 8:
            CREATE_TEXT("Don't bother me now, I'm working on the wings.", BRUCE_TEXT_LOCATION)
    elif SHOULD_INTERACT(eventPlayer.outerSmuggler):
        if not eventPlayer.canUtilizeSmuggler:
            if strContains(eventPlayer.inventory[0], "dollars"):
                CREATE_TEXT("Great! I'll sign you right up.", INSIDE_SMUGGLER_TEXT_LOCATION)
                del eventPlayer.inventory[0]
                eventPlayer.money -= SMUGGLER_COST
                if eventPlayer.money > 0:
                    GIVE_ITEM("{0} dollars".format(eventPlayer.money))
                eventPlayer.canUtilizeSmuggler = true
            else:
                CREATE_TEXT("Gotta buy a membership before we can deliver anything, love.", INSIDE_SMUGGLER_TEXT_LOCATION)
        else:
            if eventPlayer.insideSmugglerItem:
                insideMailTextPlayers.remove(eventPlayer)
                CREATE_TEXT("Looks like we have something for you!", INSIDE_SMUGGLER_TEXT_LOCATION)
                eventPlayer.tText = eventPlayer.insideSmugglerItem
                smallMessage(eventPlayer, "Received {0}".format(eventPlayer.tText))
                GIVE_ITEM(eventPlayer.insideSmugglerItem)
                eventPlayer.insideSmugglerItem = null
            elif eventPlayer.outsideSmugglerItem:
                CREATE_TEXT("Only one delivery at a time, love.", INSIDE_SMUGGLER_TEXT_LOCATION)
            elif len(eventPlayer.inventory) == 0:
                CREATE_TEXT("You want me to deliver the abstract notion of nothingness?", INSIDE_SMUGGLER_TEXT_LOCATION)
            elif strContains(eventPlayer.inventory[0], "dollars"):
                CREATE_TEXT("You already have a membership.", INSIDE_SMUGGLER_TEXT_LOCATION)
            elif eventPlayer.inventory[0] == "Odd looking coin":
                CREATE_TEXT("This is far too odd looking for me to deliver.", INSIDE_SMUGGLER_TEXT_LOCATION)
            else:
                CREATE_TEXT("You got it! We'll have the {0} outside the walls for you in a jiffy.".format(eventPlayer.inventory[0]), INSIDE_SMUGGLER_TEXT_LOCATION)
                eventPlayer.outsideSmugglerItem = eventPlayer.inventory[0]
                del eventPlayer.inventory[0]
                outsideMailTextPlayers.append(eventPlayer)
    elif SHOULD_INTERACT(eventPlayer.outsideSmuggler):
        if not eventPlayer.canUtilizeSmuggler:
            CREATE_TEXT("Gotta buy a membership before we can deliver anything.", OUTSIDE_SMUGGLER_TEXT_LOCATION)
        else:
            if eventPlayer.outsideSmugglerItem:
                outsideMailTextPlayers.remove(eventPlayer)
                CREATE_TEXT("Looks like we have something for you!", OUTSIDE_SMUGGLER_TEXT_LOCATION)
                eventPlayer.tText = eventPlayer.outsideSmugglerItem
                smallMessage(eventPlayer, "Received {0}".format(eventPlayer.tText))
                GIVE_ITEM(eventPlayer.outsideSmugglerItem)
                eventPlayer.outsideSmugglerItem = null
            elif eventPlayer.insideSmugglerItem:
                CREATE_TEXT("Only one delivery at a time, love.", OUTSIDE_SMUGGLER_TEXT_LOCATION)
            elif len(eventPlayer.inventory) == 0:
                CREATE_TEXT("You want me to deliver the abstract notion of nothingness?", OUTSIDE_SMUGGLER_TEXT_LOCATION)
            else:
                CREATE_TEXT("You got it! We'll have the {0} inside the walls for you in a jiffy.".format(eventPlayer.inventory[0]), OUTSIDE_SMUGGLER_TEXT_LOCATION)
                eventPlayer.insideSmugglerItem = eventPlayer.inventory[0]
                del eventPlayer.inventory[0]
                insideMailTextPlayers.append(eventPlayer)
    elif SHOULD_INTERACT(eventPlayer.outerBartender):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.outerBartender)
        if strContains(eventPlayer.inventory[0], "dollars"):
            if eventPlayer.tValue[Item.STATE] == 0:
                CREATE_TEXT("Here ya go, my last bottle of hard liquor.", BARTENDER_TEXT_LOCATION)
                del eventPlayer.inventory[0]
                eventPlayer.money -= ALCOHOL_COST
                if eventPlayer.money > 0:
                    GIVE_ITEM("{0} dollars".format(eventPlayer.money))
                GIVE_ITEM("Strong alcohol")
                eventPlayer.tValue[Item.STATE]++
                SAVE_STATE(eventPlayer.tValue)
            else:
                CREATE_TEXT("I've got nothing left for ya, bud.", BARTENDER_TEXT_LOCATION)
        elif len(eventPlayer.inventory) == 0:
            CREATE_TEXT("You expect to drink for free round here?", BARTENDER_TEXT_LOCATION)
        else:
            CREATE_TEXT("Ya can't pay with that.", BARTENDER_TEXT_LOCATION)
    elif SHOULD_INTERACT(eventPlayer.outerWorkbench):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.outerWorkbench)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.isDoingOuterMinigame = true
            outerMinigamePlayers.append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outerDoor21):
        if Equip.WINGS in eventPlayer.equipped:
            if eventPlayer.inventory[0] == "Odd looking coin":
                CREATE_TEXT("This needs to be shown to our leader", DOOR_21_TEXT_LOCATION)
            elif eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
                CREATE_TEXT("Give this to the one outside", DOOR_21_TEXT_LOCATION)
            elif eventPlayer.inventory[0]:
                CREATE_TEXT("This is not what we desire", DOOR_21_TEXT_LOCATION)
        else:
            CREATE_TEXT("You don't look like you're ready yet.\nCome back when you can soar.", DOOR_21_TEXT_LOCATION)
    elif SHOULD_INTERACT(eventPlayer.outerDoor22):
        if Equip.WINGS in eventPlayer.equipped:
            if eventPlayer.inventory[0] == "Odd looking coin":
                CREATE_TEXT("This needs to be shown to our leader", DOOR_22_TEXT_LOCATION)
            elif eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
                CREATE_TEXT("Give this to the one outside", DOOR_22_TEXT_LOCATION)
            elif eventPlayer.inventory[0]:
                CREATE_TEXT("This is not what we desire", DOOR_22_TEXT_LOCATION)
        else:
            CREATE_TEXT("You don't look like you're ready yet.\nCome back when you can soar.", DOOR_22_TEXT_LOCATION)
    elif SHOULD_INTERACT(eventPlayer.outerDoor23):
        if Equip.WINGS in eventPlayer.equipped:
            if eventPlayer.inventory[0] == "Odd looking coin":
                CREATE_TEXT("This needs to be shown to our leader", DOOR_23_TEXT_LOCATION)
            elif eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
                CREATE_TEXT("Give this to the one outside", DOOR_23_TEXT_LOCATION)
            elif eventPlayer.inventory[0]:
                CREATE_TEXT("This is not what we desire", DOOR_23_TEXT_LOCATION)
        else:
            CREATE_TEXT("You don't look like you're ready yet.\nCome back when you can soar.", DOOR_23_TEXT_LOCATION)
    elif SHOULD_INTERACT(eventPlayer.outerDoor24):
        if Equip.WINGS in eventPlayer.equipped:
            if eventPlayer.inventory[0] == "Odd looking coin":
                eventPlayer.currentCutscene = Cutscene.MOLE_LEADER_INTERACTION
            elif eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
                CREATE_TEXT("Give this to the one outside", DOOR_24_TEXT_LOCATION)
            elif eventPlayer.inventory[0]:
                CREATE_TEXT("This is not what we desire", DOOR_24_TEXT_LOCATION)
        else:
            CREATE_TEXT("You don't look like you're ready yet.\nCome back when you can soar.", DOOR_24_TEXT_LOCATION)
    elif SHOULD_INTERACT(eventPlayer.outerDoor25):
        if Equip.WINGS in eventPlayer.equipped:
            if eventPlayer.inventory[0] == "Odd looking coin":
                CREATE_TEXT("This needs to be shown to our leader", DOOR_25_TEXT_LOCATION)
            elif eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
                CREATE_TEXT("Give this to the one outside", DOOR_25_TEXT_LOCATION)
            elif eventPlayer.inventory[0]:
                CREATE_TEXT("This is not what we desire", DOOR_25_TEXT_LOCATION)
        else:
            CREATE_TEXT("You don't look like you're ready yet.\nCome back when you can soar.", DOOR_25_TEXT_LOCATION)
    elif SHOULD_INTERACT(eventPlayer.barnWorkbench):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.barnWorkbench)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.isDoingBarnMinigame = true
            barnMinigamePlayers.append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outsideHose):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.outsideHose)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)

            del eventPlayer.inventory[0]
            GIVE_ITEM("Water filled petrol can")
            createEffect(eventPlayer, Effect.MOIRA_ORB_HEAL_SOUND, null, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            pushEffectDeleteQueue()
            wait(2)
            popEffectDeleteQueue()
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outsideSatControl):
        eventPlayer.tValue = GET_ITEM_ENTRY(Id.outsideSatControl)
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            del eventPlayer.inventory[0]
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)
            INCREMENT_STATE(Id.outerBruce)
            doBruceContact()
        elif eventPlayer.inventory[0] == "Right handed remote":
            smallMessage(eventPlayer, "You can't use the right handed remote because you are left handed")
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outsideMolePersonRoom):
        if eventPlayer.molePersonInteractStage == 0 and eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
            eventPlayer.molePersonInteractStage++
            popTextDeleteQueue()
            smallMessage(eventPlayer, "They've already run away")
    elif SHOULD_INTERACT(eventPlayer.outsideMolePersonOuthouse):
        if eventPlayer.molePersonInteractStage == 1 and eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
            eventPlayer.molePersonInteractStage++
            popTextDeleteQueue()
            smallMessage(eventPlayer, "They've already run away")
    elif SHOULD_INTERACT(eventPlayer.outsideMolePersonCar):
        if eventPlayer.molePersonInteractStage == 2 and eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
            eventPlayer.molePersonInteractStage++
            popTextDeleteQueue()
            smallMessage(eventPlayer, "They've already run away")
    elif SHOULD_INTERACT(eventPlayer.outsideMolePersonCliff):
        if eventPlayer.molePersonInteractStage == 3 and eventPlayer.inventory[0] == MOLE_PERSON_DEVICE_NAME:
            eventPlayer.molePersonInteractStage++
            popTextDeleteQueue()
            eventPlayer.inventory.remove(MOLE_PERSON_DEVICE_NAME)
            eventPlayer.currentCutscene = Cutscene.MOLE_AGENT_INTERACTION
    else:
        pass



# SPECIAL EFFECTS

# Tutorial gate

rule "Tutorial gate barrier":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition not eventPlayer.tutorialFinished

    MAKE_DAMAGE_WALL(vect(-101.64, 10.19, -90.47), vect(-99.01, 14.05, -91.02), "Ouch!")
    MAKE_DAMAGE_WALL(vect(-94.21, 10.19, -92.06), vect(-91.58, 14.05, -92.61), "Ouch!")

    wait(WALL_CHECK_TIME, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

rule "Remove tutorial gate":
    @Event eachPlayer
    @Condition eventPlayer.tutorialFinished

    chase(eventPlayer.tutorialGate1End, vect(-99.01, 10.93, -91.03), duration=TUTORIAL_GATE_OPEN_TIME, ChaseReeval.NONE)
    chase(eventPlayer.tutorialGate2End, vect(-94.20, 10.93, -92.04), duration=TUTORIAL_GATE_OPEN_TIME, ChaseReeval.NONE)

    wait(TUTORIAL_GATE_OPEN_TIME)

    stopChasingVariable(eventPlayer.tutorialGate1End)
    stopChasingVariable(eventPlayer.tutorialGate2End)

    tutorialPlayers.remove(eventPlayer)
    graphicsQualityPlayers.remove(eventPlayer)

# Dark and scary barrier

#!define DARK_AND_SCARY_MESSAGE "It's too dark and scary out there"

rule "Create lights out barriers":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition eventPlayer.tutorialFinished
    @Condition not eventPlayer.lightsOn

    MAKE_WALL(vect(-85.53, 8, -97.39), vect(-85, 14.38, -94.87), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(vect(-104.47, 5.37, -128.85), vect(-99.85, 12.44, -107.17), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(vect(-103.34, 6.04, -140.02), vect(-102.20, 16.33, -134.55), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(vect(-99.65, 12.44, -153.76), vect(-102.71, 16, -149.09), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(vect(-97.29, 12.44, -169.53), vect(-96.75, 16, -166.99), DARK_AND_SCARY_MESSAGE)

    wait(WALL_CHECK_TIME, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Sparking wires

rule "Create sparks for generator wires":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition not eventPlayer.wiresConnected
    do:
        playEffect(eventPlayer, DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT, Color.TEAM_1, vect(-106.91, 12, -135.82), 1)
        wait(random.randint(100, 400) / 100)
    while RULE_CONDITION

# Sunlight barrier

#!define SCRAPYARD_OUTSIDE_MESSAGE_NEED_BOTH "The sun is too bright for your delicate eyes and sensitive complexion"
#!define SCRAPYARD_OUTSIDE_MESSAGE_NEED_GLASSES "The sun is too bright for your delicate eyes"
#!define SCRAPYARD_OUTSIDE_MESSAGE_NEED_SUNSCREEN "The sun is too bright for your sensitive complexion"
#!define SCRAPYARD_OUTSIDE_MESSAGE (SCRAPYARD_OUTSIDE_MESSAGE_NEED_BOTH if not eventPlayer.hasSunglasses and not eventPlayer.hasSunscreen else SCRAPYARD_OUTSIDE_MESSAGE_NEED_GLASSES if not eventPlayer.hasSunglasses else SCRAPYARD_OUTSIDE_MESSAGE_NEED_SUNSCREEN)

rule "Create sunlight barriers":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition eventPlayer.lightsOn
    @Condition not eventPlayer.canGoOutside

    MAKE_WALL(vect(-37.91, 13.26, -123.26), vect(-41.45, 16.37, -122.51), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(vect(-46.03, 7.37, -113.09), vect(-49.96, 11.37, -112.03), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(vect(-65.11, 7.43, -101.49), vect(-63.95, 11.43, -96.06), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(vect(-52.07, 13.51, -116.27), vect(-51.45, 16.35, -113.52), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(vect(-56.23, 14.48, -110.34), vect(-62.38, 17.43, -109.05), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(vect(-68.33, 12.43, -103.68), vect(-73.34, 17.6, -102.63), SCRAPYARD_OUTSIDE_MESSAGE)

    wait(WALL_CHECK_TIME, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Inner radio help message

rule "Inner radio help message":
    @Event eachPlayer
    @Condition not eventPlayer.hasFoundInnerRadio and distance(vect(-90, 6.5, -107), eventPlayer.getPosition()) < 10

    smallMessage(eventPlayer, "A radio mic next to the throne! Maybe you can call for help")

# Junkertown exit wall

#!define JUNKERTOWN_EXIT_WALL_MESSAGE "The guard will see you if you go any further"

rule "Junkertown entry wall":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition eventPlayer.canGoOutside

    MAKE_WALL(vect(-12.67, 6.20, -83.32), vect(-31.41, 16, -85.87), JUNKERTOWN_EXIT_WALL_MESSAGE)
    MAKE_WALL(vect(-41.66, 12.54, -82.73), vect(-44.69, 15.31, -80.84), JUNKERTOWN_EXIT_WALL_MESSAGE)

    wait(WALL_CHECK_TIME, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Barn outside wall

#!define BARN_OUTSIDE_MESSAGE "You could never leave the house without your little buddy"

rule "Create barn outside wall":
    @Event eachPlayer
    @Condition eventPlayer.isHog
    @Condition not eventPlayer.canLeaveBarn

    MAKE_WALL(vect(43.16, 16, -72.95), vect(46.87, 19, -73.26), BARN_OUTSIDE_MESSAGE)
    MAKE_WALL(vect(43.08, 10, -74.13), vect(42.65, 12.75, -78.85), BARN_OUTSIDE_MESSAGE)
    MAKE_WALL(vect(49.50, 10, -91.89), vect(49.17, 13, -95.62), BARN_OUTSIDE_MESSAGE)

    wait(WALL_CHECK_TIME, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Barn secret wall

rule "Create barn secret wall":
    @Event eachPlayer
    @Condition eventPlayer.isHog
    @Condition not eventPlayer.canAccessBarnSecret

    MAKE_WALL(vect(55.83, 9, -65.80), vect(52.28, 11.81, -65.50), "Enter the code first!")

    wait(WALL_CHECK_TIME, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# DVD logo effect

globalvar dvdLogoPos = vect(0.3, 0.5, 0.13)
globalvar dvdLogoDir = vect(INF, INF, 0)

rule "Create dvd logo":
    @Event global

    chase(dvdLogoPos, dvdLogoPos + dvdLogoDir, rate=0.5, ChaseReeval.DESTINATION_AND_RATE)
    createEffect(dvdLogoPlayers, Effect.SPHERE, Color.VIOLET, updateEveryTick(OUTSIDE_SAT_TO_WORLD(dvdLogoPos)), 0.17, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(dvdLogoPlayers, Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED_SOUND, null, localPlayer.getPosition(), (8 - distance(vect(-3.30, 14.20, -83.94), localPlayer.getPosition())) * 30, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

rule "DVD logo bounce x":
    @Event global
    @Condition dvdLogoPos.x <= 0.1 or dvdLogoPos.x >= 1.8 - 0.1

    dvdLogoDir = vect(-dvdLogoDir.x, dvdLogoDir.y, dvdLogoDir.z)

rule "DVD logo bounce y":
    @Event global
    @Condition dvdLogoPos.y <= 0.1 or dvdLogoPos.y >= 1 - 0.1

    dvdLogoDir = vect(dvdLogoDir.x, -dvdLogoDir.y, dvdLogoDir.z)

rule "DVD logo bounce failsafe":
    @Event global
    @Condition dvdLogoPos.x < -1 or dvdLogoPos.x > 2 or dvdLogoPos.y < -1 or dvdLogoPos.y > 2

    dvdLogoPos = vect(0.3, 0.5, 0.13)

# Junkertown entry wall

#!define JUNKERTOWN_ENTRY_WALL_MESSAGE "The Queen isn't too keen on you coming back after what happened last time"

rule "Junkertown entry wall":
    @Event eachPlayer
    @Condition eventPlayer.isHog
    @Condition eventPlayer.canLeaveBarn

    MAKE_WALL(vect(-50.22, 4.35, -41.54), vect(-48.34, 8.47, -47.74), JUNKERTOWN_ENTRY_WALL_MESSAGE)
    MAKE_WALL(vect(-48.99, 9.49, -46.47), vect(-47.91, 13.48, -50.19), JUNKERTOWN_ENTRY_WALL_MESSAGE)
    MAKE_WALL(vect(-28.33, 4.48, -64.23), vect(-25.17, 8.48, -66.02), JUNKERTOWN_ENTRY_WALL_MESSAGE)

    wait(WALL_CHECK_TIME, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Mole person hiding text

# room
rule "Mole person room shuffle text":
    @Event eachPlayer
    @Condition eventPlayer.molePersonInteractStage == 0
    @Condition distance(eventPlayer, MOLE_PERSON_ROOM_TEXT_LOCATION) < 16

    CREATE_TEXT("*shuffle shuffle*", MOLE_PERSON_ROOM_TEXT_LOCATION)

rule "Mole person room away text":
    @Event eachPlayer
    @Condition eventPlayer.molePersonInteractStage == 0
    @Condition distance(eventPlayer, MOLE_PERSON_ROOM_TEXT_LOCATION) < 10

    CREATE_TEXT("*mole away!*", MOLE_PERSON_ROOM_TEXT_LOCATION)
    wait(0.5)
    popTextDeleteQueue()

# outhouse
rule "Mole person outhouse shuffle text":
    @Event eachPlayer
    @Condition eventPlayer.molePersonInteractStage == 1
    @Condition distance(eventPlayer, MOLE_PERSON_OUTHOUSE_TEXT_LOCATION) < 12

    CREATE_TEXT("*shuffle shuffle*", MOLE_PERSON_OUTHOUSE_TEXT_LOCATION)

rule "Mole person outhouse away text":
    @Event eachPlayer
    @Condition eventPlayer.molePersonInteractStage == 1
    @Condition distance(eventPlayer, MOLE_PERSON_OUTHOUSE_TEXT_LOCATION) < 9

    CREATE_TEXT("*mole away!*", MOLE_PERSON_OUTHOUSE_TEXT_LOCATION)
    wait(0.5)
    popTextDeleteQueue()

# car
rule "Mole person car shuffle text":
    @Event eachPlayer
    @Condition eventPlayer.molePersonInteractStage == 2
    @Condition distance(eventPlayer, MOLE_PERSON_CAR_TEXT_LOCATION) < 16

    CREATE_TEXT("*shuffle shuffle*", MOLE_PERSON_CAR_TEXT_LOCATION)

rule "Mole person car away text":
    @Event eachPlayer
    @Condition eventPlayer.molePersonInteractStage == 2
    @Condition distance(eventPlayer, MOLE_PERSON_CAR_TEXT_LOCATION) < 10

    CREATE_TEXT("*mole away!*", MOLE_PERSON_CAR_TEXT_LOCATION)
    wait(0.5)
    popTextDeleteQueue()

# cliff
rule "Mole person cliff shuffle text":
    @Event eachPlayer
    @Condition eventPlayer.molePersonInteractStage == 3
    @Condition distance(eventPlayer, MOLE_PERSON_CLIFF_TEXT_LOCATION) < 16

    CREATE_TEXT("*shuffle shuffle*", MOLE_PERSON_CLIFF_TEXT_LOCATION)

rule "Mole person cliff away text":
    @Event eachPlayer
    @Condition eventPlayer.molePersonInteractStage == 3
    @Condition distance(eventPlayer, MOLE_PERSON_CLIFF_TEXT_LOCATION) < 10

    CREATE_TEXT("*mole away!*", MOLE_PERSON_CLIFF_TEXT_LOCATION)
    wait(0.5)
    popTextDeleteQueue()



# HINTS

enum HintState:
    INTRO,
    OPTION,
    HINT,
    ANSWER

def generateHints():
    if eventPlayer.isJunk:
        if not eventPlayer.lightsOn:
            # Lights out area
            eventPlayer.hintText = ["Option"]
            if not eventPlayer.wiresConnected or not eventPlayer.generatorOn:
                eventPlayer.hintText.append(
                    [
                        "Power the generator", [
                            "Hint",
                            ["It's not enough to generate power, you also have to get it to the panel"],
                            [
                                "1. Find the empty petrol can in the chest near the bottom of the stairs",
                                "2. Apply it to the barrel next to the downstairs window to fill it with petrol",
                                "3. Find the extension cord in one of the lockers",
                                "4. Apply the extension cord to the sparking wires upstairs",
                                "5. Apply the fuel filled petrol can to the ceiling high machine next to the wires",
                            ]
                        ]
                    ])
            else:
                eventPlayer.hintText.append(
                    [
                        "Turn on the lights", [
                            "Hint",
                            ["The lights need to be green. But what color is the broken switch?"],
                            [
                                "1. Look for the control panel with red lights next to the generator",
                                "2. Hit each of the five switches on the panel exactly once",
                                "If you see only the red lights floating in the air, your graphics level is set to low",
                                "instead of medium"
                            ]
                        ]
                    ])
        elif not eventPlayer.canGoOutside:
            # Inside area
            eventPlayer.hintText = ["Option"]
            if not eventPlayer.canBeTheOtherGuy:
                eventPlayer.hintText.append(
                    [
                        "Fix the radio", [
                            "Hint",
                            ["There are lots of random parts in the mech repair room, it might be useful to snoop around"],
                            [
                                "1. Find the fiddly part in the small toolbox in the mech room",
                                "2. Apply it to the workbench nearby and solve the puzzle",
                                "3. Apply the reverse polarity fiddly part to the radio microphone next to the",
                                "Queen's throne"
                            ]
                        ]
                    ])
            if Equip.SUNSCREEN not in eventPlayer.equipped:
                eventPlayer.hintText.append(
                    [
                        "Find the vent key", [
                            "Hint",
                            ["Three whole valves? You might even have to leave the room to do this one"],
                            [
                                "1. Turn off the three valves: the first one is in the mech room, next to the left exit",
                                "2. Follow the left wall out of the mech room until you see a second valve, just before",
                                "exiting into the payload area",
                                "3. Find the last valve in the room left of second checkpoint, with the stalled car outside",
                                "4. Look in the vent on the other side of the wall from the third valve and find the vent key",
                                "5. Use the vent key on the lower large toolbox in the mech room, next to the workbench"
                            ]
                        ]
                    ])
            if Equip.SUNGLASES not in eventPlayer.equipped:
                eventPlayer.hintText.append(
                    [
                        "Find a way to protect your eyes", [
                            "Hint",
                            ["You left a map back at your place, but there's no way to get it without going outside the walls"],
                            [
                                "1. You must have already fixed the radio and escaped the barn as Hog",
                                "2. Switch to Hog",
                                "3. Find a map in the fridge inside Junk's house (the one with the big crown)",
                                "4. Switch to Junk and find the sunglasses where the flashing red dot was"
                            ]
                        ]
                    ])
        else:
            # Inner area
            eventPlayer.hintText = ["Option"]
            if eventPlayer.money == 0 and not eventPlayer.canUtilizeSmuggler:
                eventPlayer.hintText.append(
                    [
                        "Make some money", [
                            "Hint",
                            ["Bars are always looking for entertainment"],
                            [
                                "1. Find a hilarious costume in the toolbox in the tattoo parlor (attacker third spawn)",
                                "2. Talk to the not smuggler in the bar (defender first spawn)",
                                "3. Interact with the radio on the stage",
                                "4. Talk to the not smuggler"
                            ]
                        ]
                    ])
            if not eventPlayer.canUtilizeSmuggler:
                eventPlayer.hintText.append(
                    [
                        "Hire the smuggler", [
                            "Hint",
                            ["Did you try looking up?"],
                            [
                                "1. Make sure you've already made some money",
                                "2. Apply money to the smuggler above Bruce's place"
                            ]
                        ]
                    ])
            eventPlayer.tValue = GET_ITEM_ENTRY(Id.outerBruce)
            if eventPlayer.tValue[Item.STATE] == 0:
                eventPlayer.hintText.append(
                    [
                        "Contact Bruce", [
                            "Hint",
                            ["Bruce doesn't like strangers, but maybe an old friend could vouch for you"],
                            [
                                "1. Make sure you've already hired the smuggler and escaped the barn as Hog",
                                "2. Find the right handed remote in one of the toolboxes in Bruce's place",
                                "3. Give the remote to the smuggler",
                                "4. Switch to Hog and retrieve the remote",
                                "5. Check the hints as Hog for the rest of the solution"
                            ]
                        ]
                    ])
            if eventPlayer.tValue[Item.STATE] > 0 and eventPlayer.tValue[Item.STATE] <= 8 and eventPlayer.tValue[Item.STATE] % 2 == 1:
                eventPlayer.hintText.append(
                    [
                        "Find a black battery", [
                            "Hint",
                            ["Tattoo parlors can do some amazing things with inks these days"],
                            [
                                "1. Find a red battery in a chest in the mech room by third point",
                                "2. Apply the red battery to the workbench in the tattoo parlor (attacker third spawn)",
                                "and solve the puzzle",
                            ]
                        ]
                    ])
            if eventPlayer.tValue[Item.STATE] > 0 and eventPlayer.tValue[Item.STATE] <= 8 and (eventPlayer.tValue[Item.STATE] - 1) % 4 < 2:
                eventPlayer.hintText.append(
                    [
                        "Find water", [
                            "Hint",
                            ["They say there's no clean water in Junkertown. Is it any better outside?"],
                            [
                                "1. Make sure you've already hired the smuggler",
                                "2. Give the empty petrol can to the smuggler",
                                "3. Switch to Hog and retrieve the empty petrol can",
                                "4. Apply the empty petrol can to the hose leading down from the nearby water tower",
                                "5. Give the resulting water filled petrol can back to the smuggler",
                                "6. Switch to Junk and retrieve the empty petrol can"
                            ]
                        ]
                    ])
            if eventPlayer.tValue[Item.STATE] > 0 and eventPlayer.tValue[Item.STATE] <= 4:
                eventPlayer.hintText.append(
                    [
                        "Find strong alcohol", [
                            "Hint",
                            ["What's the point of a bar again?"],
                            [
                                "1. Make sure you've already made some money",
                                "2. Apply money to the bartender behind the bar (defender first spawn)"
                            ]
                        ]
                    ])
            if Equip.WINGS in eventPlayer.equipped:
                eventPlayer.hintText.append(
                    [
                        "Find a way out", [
                            "Hint",
                            ["They talk in riddles, but it seems you need to give the coin to the right door"],
                            [
                                "1. Make sure you have the odd looking coin, which can be found in the green safe in",
                                "the starting room",
                                "2. Find the doors on the second floor above the Chinese place and tattoo parlor",
                                "3. Apply the odd looking coin to door 24",
                                "4. Give the Anathema Device to the smuggler",
                                "5. Check the hints as Hog for the rest of the solution",
                                "6. When you've completed Hog's tasks, interact with door 24 again"
                            ]
                        ]
                    ])
    else:
        if not eventPlayer.canLeaveBarn:
            # Barn
            eventPlayer.hintText = [
                "Option",
                "Leave the barn", [
                    "Hint",
                    ["You swear you wrote the code down somewhere, but you lost the papers"],
                    [
                        "1. You need find the code to unlock the secret area under the stairs",
                        "2. Find the first two digits on the sparkling paper by the right exit",
                        "3. Find the middle digit on the motorbike",
                        "4. Find the last two digits on the sparkling paper by the upstairs exit",
                        "5. Input the code in the panel by hitting the switches where 1 is the top switch",
                        "and 5 is the bottom switch",
                        "6. Find your little buddy in the open safe in the hidden area"
                    ]
                ]
            ]
        else:
            # Outside area
            eventPlayer.hintText = ["Option"]
            if Equip.SUNGLASES not in eventPlayer.junkEquipped:
                eventPlayer.hintText.append(
                    [
                        "Find a way to protect Junk's eyes", [
                            "Hint",
                            ["It's amazing what Junk will leave in his refrigerator"],
                            [
                                "1. Find a map in the fridge inside Junk's house (the one with the big crown)",
                                "2. Switch to Junk and find the sunglasses where the flashing red dot was"
                            ]
                        ]
                    ])
            eventPlayer.tValue = GET_ITEM_ENTRY(Id.outerBruce)
            if eventPlayer.canGoOutside and eventPlayer.tValue[Item.STATE] == 0:
                eventPlayer.hintText.append(
                    [
                        "Contact Bruce", [
                            "Hint",
                            ["Maybe you could get Bruce's spare remote, but you'd still have to mess with it in your shop"],
                            [
                                "1. Make sure you've escaped the barn, and have the right handed remote (check hints as Junk)",
                                "2. Apply the right handed remote to the workbench in the barn and solve the puzzle",
                                "3. Find the TV with the bouncing logo in the room above the car garage",
                                "4. Apply the left handed remote to the TV"
                            ]
                        ]
                    ])
            if Equip.WINGS in eventPlayer.junkEquipped:
                eventPlayer.hintText.append(
                    [
                        "Track down the mole", [
                            "Hint",
                            ["They keep running away, but maybe the ones inside know where they went?"],
                            [
                                "1. Make sure you have the Anathema Device (check hints as Junk, \"Find a way out\")",
                                "2. Go to attacker second spawn and apply the device to where you see the shuffling text",
                                "3. Go to the outhouse to the left when exiting the barn and apply the device to where",
                                "you see the shuffling text",
                                "4. Go to the two stacked cars by attacker second spawn and apply the device to where you",
                                "see the shuffling text",
                                "5. Go to where the cliff meets the city walls near where you contacted Bruce and apply",
                                "the device to where you see the shuffling text"
                            ]
                        ]
                    ])

    if eventPlayer.isOnSecondRun:
        eventPlayer.hintText.append(
            [
                "Achievements", [
                    "Hint",
                    [
                        "Most wanted: find all the posters of you",
                        "Infrasight: find the sunglasses without using the map",
                        "Puzzle master: solve the color puzzle in 5 moves",
                        "In a hurry: pester Bruce 60 times",
                        "Master hacker: glitch through the walls and enjoy the view",
                        "Escape artist: get out of Junkertown"
                    ],
                    [
                        "You'll have to figure these ones out yourself. Good luck!",
                    ]
                ]
            ])

#!define HINT_SPACING_TEXT "\n                                                                                                                                                                                                "
#!define HINT_SPACING_CONTROLS "\n                                                                                                                                                                                                                                                                "
#!define HINT_LINE_OFFSET 5

def generateHintText():
    popAllTextDeleteQueue()

    if eventPlayer.hintText[0] == "Option":
        eventPlayer.tValue = HintState.OPTION

        CREATE_BLACK_TEXT_REEVAL("{0} / {1}: scroll{2}".format(buttonString(Button.ULTIMATE), buttonString(Button.ABILITY_2), HINT_SPACING_CONTROLS), -3 - HINT_LINE_OFFSET)
        CREATE_BLACK_TEXT_REEVAL("{0}: select{1}".format(buttonString(Button.JUMP), HINT_SPACING_CONTROLS), -2 - HINT_LINE_OFFSET)

        eventPlayer.tIndex = 0
        eventPlayer.tPos = 0
        CREATE_MOVABLE_TEXT(">" HINT_SPACING_TEXT "        ", eventPlayer.tIndex - HINT_LINE_OFFSET, 1, Color.RED)

        for eventPlayer.I in range(1, len(eventPlayer.hintText), 2):
            CREATE_BLACK_TEXT("{0}{1}".format(eventPlayer.hintText[eventPlayer.I], HINT_SPACING_TEXT), (eventPlayer.I - 1) / 2 - HINT_LINE_OFFSET)
    elif eventPlayer.hintText[0] == "Hint":
        eventPlayer.tValue = HintState.HINT

        for eventPlayer.I in range(len(eventPlayer.hintText[1])):
            CREATE_BLACK_TEXT("{0}{1}".format(eventPlayer.hintText[1][eventPlayer.I], HINT_SPACING_TEXT), eventPlayer.I - HINT_LINE_OFFSET)

        CREATE_BLACK_TEXT_REEVAL("{0}: Show full answer{1}".format(buttonString(Button.INTERACT), HINT_SPACING_CONTROLS), 4)
    else:
        eventPlayer.tValue = HintState.ANSWER

        for eventPlayer.I in range(len(eventPlayer.hintText)):
            CREATE_BLACK_TEXT("{0}{1}".format(eventPlayer.hintText[eventPlayer.I], HINT_SPACING_TEXT), eventPlayer.I - HINT_LINE_OFFSET)

    CREATE_BLACK_TEXT_REEVAL("{0}: exit{1}".format(buttonString(Button.RELOAD), HINT_SPACING_CONTROLS), 5)


def showHintIntro():
    FADE_TO_BLACK()
    CREATE_BLACK_TEXT("Use hints to help you out if you get stuck", -2)
    CREATE_BLACK_TEXT("Hints change based on your progress and location", 0)
    CREATE_BLACK_TEXT_REEVAL("{0} to continue".format(buttonString(Button.PRIMARY_FIRE)), 2)

def showHintScreen():
    generateHints()
    generateHintText()

rule "Toggle hints":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) and eventPlayer.tutorialFinished and (eventPlayer.isDoingHint or not eventPlayer.pauseInteraction)

    eventPlayer.isDoingHint = not eventPlayer.isDoingHint
    if eventPlayer.isDoingHint:
        freeze()
        hideUi()
        eventPlayer.tValue = HintState.INTRO
        showHintIntro()
    else:
        showUi()
        popAllTextDeleteQueue()
        eventPlayer.stopCamera()
        unfreeze()

rule "Pass hint intro":
    @Event eachPlayer
    @Condition eventPlayer.isDoingHint
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    @Condition eventPlayer.tValue == HintState.INTRO

    showHintScreen()

rule "Select hint option":
    @Event eachPlayer
    @Condition eventPlayer.isDoingHint
    @Condition eventPlayer.isHoldingButton(Button.JUMP)
    @Condition eventPlayer.tValue == HintState.OPTION

    eventPlayer.hintText = eventPlayer.hintText[eventPlayer.tIndex * 2 + 2]
    generateHintText()

rule "Scroll hint option down":
    @Event eachPlayer
    @Condition eventPlayer.isDoingHint
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
    @Condition eventPlayer.tValue == HintState.OPTION

    eventPlayer.tIndex++
    if eventPlayer.tIndex >= (len(eventPlayer.hintText) - 1) / 2:
        eventPlayer.tIndex = 0

rule "Scroll hint option up":
    @Event eachPlayer
    @Condition eventPlayer.isDoingHint
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    @Condition eventPlayer.tValue == HintState.OPTION

    eventPlayer.tIndex--
    if eventPlayer.tIndex < 0:
        eventPlayer.tIndex = (len(eventPlayer.hintText) - 1) / 2 - 1

rule "Show answer":
    @Event eachPlayer
    @Condition eventPlayer.isDoingHint
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition eventPlayer.tValue == HintState.HINT

    eventPlayer.hintText = eventPlayer.hintText[2]
    generateHintText()



# DEBUG FUNCTIONS

globalvar debugPlayer

rule "Set debug player":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.ABILITY_2) and eventPlayer.isHoldingButton(Button.JUMP)

    wait(5, Wait.ABORT_WHEN_FALSE)

    if debugPlayer:
        debugPlayer = 0
        eventPlayer.disableScoreboard()
        eventPlayer.setMoveSpeed(100)
        smallMessage(eventPlayer, "Debug player unset")
    else:
        debugPlayer = eventPlayer
        eventPlayer.enableScoreboard()
        smallMessage(eventPlayer, "Debug player set")

playervar pointHelperEffect
playervar pointHelperHud
playervar pointHelperState = 0

rule "Point helper":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer == debugPlayer

    eventPlayer.canBeTheOtherGuy = true

    if eventPlayer.pointHelperState == 0:
        hudHeader(eventPlayer, "Position: {0}".format(updateEveryTick(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 3, getAllPlayers(), eventPlayer, true).getHitPosition())), HudPosition.LEFT, 99, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.pointHelperHud = getLastCreatedText()
        createEffect(eventPlayer, Effect.SPHERE, Color.RED, updateEveryTick(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 3, getAllPlayers(), eventPlayer, true).getHitPosition()), 0.05, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        eventPlayer.pointHelperEffect = getLastCreatedEntity()
        eventPlayer.pointHelperState = 1
    elif eventPlayer.pointHelperState == 1:
        destroyEffect(eventPlayer.pointHelperEffect)
        destroyHudText(eventPlayer.pointHelperHud)
        hudHeader(eventPlayer, "Position: {0}".format(updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 3)), HudPosition.LEFT, 99, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        eventPlayer.pointHelperHud = getLastCreatedText()
        createEffect(eventPlayer, Effect.SPHERE, Color.RED, updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 3), 0.05, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
        eventPlayer.pointHelperEffect = getLastCreatedEntity()
        eventPlayer.pointHelperState = 2
    else:
        destroyEffect(eventPlayer.pointHelperEffect)
        destroyHudText(eventPlayer.pointHelperHud)
        eventPlayer.pointHelperState = 0

rule "Item visualization":
    @Event eachPlayer
    @Condition eventPlayer == debugPlayer

    # for eventPlayer.tText in range(len(eventPlayer.itemPoints)):
    #     if Id.innerFridge <= eventPlayer.itemPoints[eventPlayer.tText][Item.ID] and eventPlayer.itemPoints[eventPlayer.tText][Item.ID] <= Id.innerPowerBox:
    #         createEffect(debugPlayer, Effect.SPHERE, Color.PURPLE, eventPlayer.itemPoints[eventPlayer.tText][Item.POINT], eventPlayer.itemPoints[eventPlayer.tText][Item.RADIUS], EffectReeval.VISIBILITY)

playervar isGoingFast = false

rule "Toggle zoomies":
    @Event eachPlayer
    @Condition eventPlayer == debugPlayer
    @Condition eventPlayer.isHoldingButton(Button.JUMP) and eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.isGoingFast = not eventPlayer.isGoingFast
    if eventPlayer.isGoingFast:
        eventPlayer.setMoveSpeed(200)
    else:
        eventPlayer.setMoveSpeed(100)

rule "Easy restart":
    @Event eachPlayer
    @Condition eventPlayer == debugPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)

    restartMatch()

rule "Noclip on":
    @Event eachPlayer
    @Condition eventPlayer == debugPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true

    eventPlayer.disableEnvironmentCollision(false)

rule "Noclip off":
    @Event eachPlayer
    @Condition eventPlayer == debugPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == false

    eventPlayer.enableEnvironmentCollision()

rule "End game state":
    @Event eachPlayer
    @Condition eventPlayer == debugPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    eventPlayer.molePersonInteractStage = 4
    eventPlayer.equipped.append(Equip.WINGS)
    manageEquips()
    eventPlayer.achievements = [2, 3, 4, 1, 5]
    manageAchievements()

rule "Display stats":
    @Event global

    hudHeader(debugPlayer, "load {0}".format(getServerLoad()), HudPosition.RIGHT, 11, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudHeader(debugPlayer, "peak {0}".format(getPeakServerLoad()), HudPosition.RIGHT, 12, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudHeader(debugPlayer, "avg {0}".format(getAverageServerLoad()), HudPosition.RIGHT, 13, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
    hudHeader(debugPlayer, "effects {0}".format(getNumberOfEntityIds()), HudPosition.RIGHT, 14, Color.VIOLET, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
