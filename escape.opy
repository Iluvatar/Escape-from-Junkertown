settings {
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
            "mercy": {
                "jumpVerticalSpeed%": 250,
                "movementSpeed%": 200,
                "enableInfiniteAmmo": true,
                "enableMelee": false,
                "enableSpawningWithUlt": true,
                "combatUltGen%": 500,
                "passiveUltGen%": 500,
                "ultGen%": 500,
                "weaponsEnabled": "blaster"
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

#!define SUNLIGHT_ANGLE 30
#!define INTERACT_DISTANCE 4
#!define WALL_MESSAGE_TIMEOUT 3
#!define POWER_OFF_COLOR Color.RED
#!define POWER_BROKEN_COLOR Color.BLACK
#!define ALCOHOL_COST 60
#!define SMUGGLER_COST 100

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

#!define MOLE_PERSON_TEXT_LOCATION vect(-51.97, 6.14 + 0.6, -3.03)

#!define OUTER_MINIGAME_BALL_SIZE 0.05



# GLOBAL VARIABLES

globalvar introStage1Players = []
globalvar introStage2Players = []
globalvar playersInDark = []
globalvar innerWirePlayers = []
globalvar powerPanelPlayers = [[], [], [], [], []]
globalvar innerMinigamePlayers = []
globalvar radioSmokePlayers = []
globalvar outerMinigamePlayers = []
globalvar barnHintPlayers = []
globalvar mapMarkerPlayers = []
globalvar satUntunedPlayers = [[], [], [], []]
globalvar satTunedPlayers = [[], [], [], []]

# equippables
enum Equip:
    HAS_ANY = 0,
    LITTLE_BUDDY,
    SUNSCREEN,
    SUNGLASES,
    WINGS

globalvar equipPlayers = [[], [], [], [], []]

# achievements
enum Achievement:
    HAS_ANY = 0,
    MOST_WANTED, # find all the posters
    INFRASIGHT, # find the sunglasses without using the map
    PUZZLE_MASTER, # finish the color minigame in 5 moves
    IN_A_HURRY, # click on Bruce 60 times before the minute is up
    ESCAPE_ARTIST, # escape Junkertown
    END_MARKER # always at the end, the number of total achievements


globalvar achievementPlayers = [[], [], [], [], [], []]

# NPCs

globalvar cartNpc
globalvar bruceNpc
globalvar outsideSmugglerNpc
globalvar insideSmugglerNpc
globalvar bartenderNpc
globalvar barnNpc

# other
globalvar outerMinigameColors = [Color.RED, Color.BLACK]


# PLAYER VARIABLES

playervar effectDeleteQueue = []
playervar textDeleteQueue = []

playervar argStack = []

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
playervar junkEquipped
playervar hogEquipped
playervar equipped
playervar smugglerItem
playervar money
playervar achievements
playervar inSunlight

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

playervar isMolePersonFriend

playervar bruceTimer

playervar satsTuned

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

playervar outsideSmuggler
playervar outsideMolePerson
playervar outsideHose
playervar outsideSat1
playervar outsideSat2
playervar outsideSat3
playervar outsideSat4



# UTILITIES

# function hacks
#!define ARG_STACK_PEEK() eventPlayer.argStack.last()
def ARG_STACK_POP():
    del eventPlayer.argStack[len(eventPlayer.argStack) - 1]
#!define PUSH_ARGS_1(arg1) eventPlayer.argStack.append(arg1)
#!define PUSH_ARGS_2(arg1, arg2) eventPlayer.argStack.append(arg1) \
eventPlayer.argStack.append(arg2)
#!define PUSH_ARGS_3(arg1, arg2, arg3) eventPlayer.argStack.append(arg1) \
eventPlayer.argStack.append(arg2) \
eventPlayer.argStack.append(arg3)

# 2d arrays can't be modified directly, so we have to pull out a row, modify it, then reinsert it

# get an item entry by id
#!define GET_ITEM_ENTRY(id) [elem for elem in eventPlayer.itemPoints if elem[Item.ID] == id][0]

# save an item entry
#!define SAVE_STATE(item) eventPlayer.tIndex = eventPlayer.itemIds.index(item[Item.ID]) \
eventPlayer.itemPoints[eventPlayer.tIndex] = item

# distance between two vectors ignoring the height component
#!define DIST_2D(v1, v2) distance(vect((v1).x, 0, (v1).z), vect((v2).x, 0, (v2).z))

# distance from pos to the vertical plane defined by start and end vectors
#!define DIST_TO_WALL(start, end, pos) (sinDeg(angleBetweenVectors(vect(end.x - start.x, 0, end.z - start.z), vect(pos.x - start.x, 0, pos.z - start.z))) * DIST_2D(start, pos))

#!define DIST_TO_WALL_2(start, end, pos) dotProduct(normalize(vect(-((end) - (start)).z, 0, ((end) - (start)).x)), start - pos)

# MAKE_WALL creates a vertical wall from start to end, pushing 90 degrees clockwise to the (end - start) vector
# when hit, displays the message, but with a timeout of WALL_MESSAGE_TIMEOUT
# it's an instantaneous check, so must be rerun every tick
playervar isShowingWallMessage = false

def doWallMessageTimeout():
    eventPlayer.isShowingWallMessage = true
    wait(WALL_MESSAGE_TIMEOUT)
    eventPlayer.isShowingWallMessage = false

#!define MAKE_WALL(start, end, message) if DIST_2D(((start) + (end)) / 2, eventPlayer.getPosition()) < distance(start, end) / 2 and eventPlayer.getPosition().y >= start.y and eventPlayer.getPosition().y <= end.y and DIST_TO_WALL(start, end, eventPlayer.getPosition()) < 1: \
    eventPlayer.setMoveSpeed(5) \
    eventPlayer.applyImpulse(vect(-((end) - (start)).z, 0, ((end) - (start)).x), 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION) \
    if eventPlayer.isShowingWallMessage == false: \
        smallMessage(eventPlayer, message) \
        async(doWallMessageTimeout(), AsyncBehavior.RESTART) \
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

# Push and pop text using the text deletion queue
def pushTextDeleteQueue():
    eventPlayer.textDeleteQueue.append(getLastCreatedText())

def popTextDeleteQueue():
    destroyInWorldText(eventPlayer.textDeleteQueue[0])
    del eventPlayer.textDeleteQueue[0]

# Creates in world text for the event player
#!define CREATE_TEXT(text, location) popTextDeleteQueue() \
createInWorldText(eventPlayer, text, location, 1, Clip.NONE, WorldTextReeval.NONE, Color.WHITE, SpecVisibility.NEVER) \
pushTextDeleteQueue()

# Used to turn the whole screen black (doesn't actually fade)
#!define BLACK_SCREEN_POS vect(34, 6, -88)
#!define BLACK_SCREEN_FACING vect(0, -1, 0)
#!define FADE_TO_BLACK() eventPlayer.startCamera(BLACK_SCREEN_POS, BLACK_SCREEN_POS + BLACK_SCREEN_FACING, 0)

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

        # Zen drop
        async(openSecretDoor(), AsyncBehavior.NOOP)

# Makes a noise for when a switch is pressed
def makeSwitchNoise():
    createEffect(eventPlayer, Effect.ECHO_FOCUSING_BEAM_SOUND, null, eventPlayer, 100, EffectReeval.NONE)
    pushEffectDeleteQueue()
    wait(0.3)
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
    barnNpc.forceButtonPress(Button.ULTIMATE)
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

    disableAnnouncer()
    disableGamemodeCompletion()
    setObjectiveDescription(getAllPlayers(), "Escape", HudReeval.VISIBILITY_AND_STRING)
    startForcingSpawn(Team.2, 2)
    getAllPlayers().disableNameplatesFor(getAllPlayers())

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
    hudHeader(equipPlayers[Equip.WINGS], "{0} Mechanical wings".format(abilityIconString(Hero.MERCY, Button.ULTIMATE)), HudPosition.LEFT, 5, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.NEVER)

    # achievement hud text
    hudHeader(achievementPlayers[Achievement.HAS_ANY], "Achievements", HudPosition.RIGHT, 1, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.MOST_WANTED], "Most wanted {0}".format(abilityIconString(Hero.MCCREE, Button.ULTIMATE)), HudPosition.RIGHT, 2, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.INFRASIGHT], "Infrasight {0}".format(abilityIconString(Hero.WIDOWMAKER, Button.ULTIMATE)), HudPosition.RIGHT, 3, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.PUZZLE_MASTER], "Puzzle master {0}".format(abilityIconString(Hero.LUCIO, Button.JUMP)), HudPosition.RIGHT, 4, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.IN_A_HURRY], "In a hurry {0}".format(abilityIconString(Hero.SOLDIER, Button.ABILITY_1)), HudPosition.RIGHT, 5, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudHeader(achievementPlayers[Achievement.ESCAPE_ARTIST], "Escape artist {0}".format(abilityIconString(Hero.BAPTISTE, Button.ULTIMATE)), HudPosition.RIGHT, 6, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.NEVER)

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
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-95.12, 8.43, -111.36), 9, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-95.32, 8.43, -111.36), 9, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-95.52, 8.43, -111.36), 9, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-95.72, 8.43, -111.36), 9, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-95.92, 8.43, -111.36), 9, EffectReeval.VISIBILITY)

    # window 2
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.15, 8, -118.84), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.35, 8, -118.84), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.55, 8, -118.84), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.75, 8, -118.84), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.95, 8, -118.84), 5, EffectReeval.VISIBILITY)

    # window 3
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.12, 8.43, -127.46), 9, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.32, 8.43, -127.46), 9, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.52, 8.43, -127.46), 9, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.72, 8.43, -127.46), 9, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-97.92, 8.43, -127.46), 9, EffectReeval.VISIBILITY)

    # window 4
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.17, 8, -137.46), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.37, 8, -137.46), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.57, 8, -137.46), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.77, 8, -137.46), 5, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.97, 8, -137.46), 5, EffectReeval.VISIBILITY)

    # window 5
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -136), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -137), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -138), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -139), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -140), 3, EffectReeval.VISIBILITY)

    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -136), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -137), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -138), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -139), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.5, 13.5, -140), 3, EffectReeval.VISIBILITY)

    # # window 6
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.83, 13.5, -153.41), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.54, 13.5, -152.50), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-101.18, 13.5, -151.41), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.95, 13.5, -150.25), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.52, 13.5, -149.31), 3, EffectReeval.VISIBILITY)
    
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.83, 13.5, -153.41), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.54, 13.5, -152.50), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-101.18, 13.5, -151.41), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.95, 13.5, -150.25), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.52, 13.5, -149.31), 3, EffectReeval.VISIBILITY)

    # window 7
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-93.95, 11.44, -169.05), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-93.95, 11.94, -169.05), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-93.95, 12.44, -169.05), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-93.95, 12.94, -169.05), 3, EffectReeval.VISIBILITY)

    # inner workbench puzzle
    createEffect(innerMinigamePlayers, Effect.SPHERE, Color.GRAY, vect(-103.45, 8.89, -184.36), 0.04, EffectReeval.VISIBILITY)
    createEffect(innerMinigamePlayers, Effect.SPHERE, Color.GRAY, vect(-103.50, 8.89, -184.63), 0.04, EffectReeval.VISIBILITY)
    createBeam(innerMinigamePlayers, Beam.TORBJORN_TURRET_SIGHT, INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6) * 0.2, 0.451 + cos(PI / 6) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6 + 2 * PI / 3) * 0.2, 0.451 + cos(PI / 6 + 2 * PI / 3) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(innerMinigamePlayers, Beam.TORBJORN_TURRET_SIGHT, INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6 + 2 * PI / 3) * 0.2, 0.451 + cos(PI / 6 + 2 * PI / 3) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6 + 4 * PI / 3) * 0.2, 0.451 + cos(PI / 6 + 4 * PI / 3) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(innerMinigamePlayers, Beam.TORBJORN_TURRET_SIGHT, INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6 + 4 * PI / 3) * 0.2, 0.451 + cos(PI / 6 + 4 * PI / 3) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), INNER_MINIGAME_2D_TO_3D(vect(0.801 + sin(3 * PI / 2) * 0.422 + sin(PI / 6) * 0.2, 0.451 + cos(PI / 6) * 0.2 + sin(3 * PI / 2 * 2) * 0.15, 0)), null, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(innerMinigamePlayers, Effect.SPHERE, Color.BLACK, INNER_MINIGAME_2D_TO_3D(vect(1.48, 0.73, 0)), 0.05, EffectReeval.VISIBILITY)
    createInWorldText(innerMinigamePlayers, "skip", INNER_MINIGAME_2D_TO_3D(vect(1.48, 0.73 + 0.04, 0)), 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)

    # radio smoke effect
    createEffect(radioSmokePlayers, Effect.CLOUD, Color.BLACK, vect(-90.05, 8.69, -103.28), 0.1, EffectReeval.VISIBILITY)

    # outer workbench puzzle
    createEffect(outerMinigamePlayers, Effect.SPHERE, Color.GRAY, OUTER_MINIGAME_2D_TO_3D(vect(0.92, 0.08 + 0.17 / 3, 0)), 0.03, EffectReeval.VISIBILITY)
    createEffect(outerMinigamePlayers, Effect.SPHERE, Color.GRAY, OUTER_MINIGAME_2D_TO_3D(vect(0.52, 0.08 + 0.17 / 3, 0)), 0.03, EffectReeval.VISIBILITY)
    createEffect(outerMinigamePlayers, Effect.SPHERE, Color.GRAY, OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17 * 7 / 3, 0)), 0.03, EffectReeval.VISIBILITY)
    createEffect(outerMinigamePlayers, Effect.SPHERE, Color.BLACK, OUTER_MINIGAME_2D_TO_3D(vect(1.15, 0.59, 0)), 0.05, EffectReeval.VISIBILITY)
    createInWorldText(outerMinigamePlayers, "skip", OUTER_MINIGAME_2D_TO_3D(vect(1.15, 0.59 + 0.04, 0)), 1, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.NEVER)

    # map marker
    createEffect(mapMarkerPlayers, Effect.SPHERE, Color.RED, vect(-88.04, 13.37, -158.22), 0.5, EffectReeval.VISIBILITY)

    # barn paper clues
    createEffect(barnHintPlayers, Effect.SPARKLES, Color.BLUE, vect(58.30, 8.2, -93.83), 0.3, EffectReeval.VISIBILITY)
    createEffect(barnHintPlayers, Effect.SPARKLES, Color.BLUE, vect(42.25, 15.2, -71.88), 0.3, EffectReeval.VISIBILITY)

    # satellite beam
    createBeam(satUntunedPlayers[0], Beam.ECHO_FOCUSING, vect(25.774, 16.251, -90.842), vect(25.774, 16.251, -90.842) + 100 * vect(0.542, 0.416, 0.730), Color.TEAM_2, EffectReeval.VISIBILITY)
    createBeam(satUntunedPlayers[1], Beam.ECHO_FOCUSING, vect(12.000, 17.647, -88.850), vect(12.000, 17.647, -88.850) + 100 * vect(0.529, 0.427, 0.733), Color.TEAM_2, EffectReeval.VISIBILITY)
    createBeam(satUntunedPlayers[2], Beam.ECHO_FOCUSING, vect(-1.572, 16.131, -58.995), vect(-1.572, 16.131, -58.995) + 100 * vect(0.693, 0.460, -0.555), Color.TEAM_2, EffectReeval.VISIBILITY)
    createBeam(satUntunedPlayers[3], Beam.ECHO_FOCUSING, vect(6.139, 17.041, -44.789), vect(6.139, 17.041, -44.789) + 100 * vect(-0.551, 0.428, 0.716), Color.TEAM_2, EffectReeval.VISIBILITY)

    createBeam(satTunedPlayers[0], Beam.TORBJORN_TURRET_SIGHT, vect(25.774, 16.251, -90.842), vect(25.774, 16.251, -90.842) + 100 * vect(0.542, 0.416, 0.730), Color.TEAM_1, EffectReeval.VISIBILITY)
    createBeam(satTunedPlayers[1], Beam.TORBJORN_TURRET_SIGHT, vect(12.000, 17.647, -88.850), vect(12.000, 17.647, -88.850) + 100 * vect(0.529, 0.427, 0.733), Color.TEAM_1, EffectReeval.VISIBILITY)
    createBeam(satTunedPlayers[2], Beam.TORBJORN_TURRET_SIGHT, vect(-1.572, 16.131, -58.995), vect(-1.572, 16.131, -58.995) + 100 * vect(0.693, 0.460, -0.555), Color.TEAM_1, EffectReeval.VISIBILITY)
    createBeam(satTunedPlayers[3], Beam.TORBJORN_TURRET_SIGHT, vect(6.139, 17.041, -44.789), vect(6.139, 17.041, -44.789) + 100 * vect(-0.551, 0.428, 0.716), Color.TEAM_1, EffectReeval.VISIBILITY)

def showIntro():
    wait(1)
    eventPlayer.disableHeroHUD()
    eventPlayer.setStatusEffect(null, Status.ROOTED, INF)
    eventPlayer.setInvisibility(Invis.ALL)
    introStage1Players.append(eventPlayer)

    FADE_TO_BLACK()

    wait(3.5)

    # Stage 1, view of plan
    eventPlayer.tPos = vect(45.98, 11.12, -71.48) + vect(-1, -0.01, 0.10) * 0.3
    eventPlayer.startCamera(eventPlayer.tPos, vect(45.98, 11.12, -71.48) + vect(-1, -0.01, 0.10), 0)
    chase(eventPlayer.tPos, vect(45.98, 11.12, -71.48) - vect(-1, -0.01, 0.10) * 0.2, duration=3.3, ChaseReeval.DESTINATION_AND_DURATION)

    wait(3.3)

    stopChasingVariable(eventPlayer.tPos)

    # Stage 2, following cart path
    smallMessage(eventPlayer, "But something went wrong")

    eventPlayer.tStart = vect(7.12, 8.28, -69.01)
    eventPlayer.tEnd = vect(13.34, 8.38, -56.17)
    eventPlayer.tIndex = 0

    chase(eventPlayer.tStart, vect(13.34, 8.38, -56.17), duration=3.3, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.tEnd, vect(-4.86, 7.87, -44.03), duration=3.3, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.tIndex, 1, duration=3.3, ChaseReeval.DESTINATION_AND_DURATION)
    eventPlayer.startCamera(eventPlayer.tStart + (eventPlayer.tEnd - eventPlayer.tStart) * eventPlayer.tIndex, eventPlayer.tEnd, 0)

    wait(3.3)

    stopChasingVariable(eventPlayer.tStart)
    stopChasingVariable(eventPlayer.tEnd)
    stopChasingVariable(eventPlayer.tIndex)

    # Stage 3, view of posters
    eventPlayer.tPos = vect(-36.85, 5.72, -72.38) + vect(0.55, 0.12, 0.83) * 0.3
    eventPlayer.startCamera(eventPlayer.tPos, vect(-36.85, 5.72, -72.38) + vect(0.55, 0.12, 0.83), 0)
    chase(eventPlayer.tPos, vect(-36.85, 5.72, -72.38) - vect(0.55, 0.12, 0.83) * 0.2, duration=3.3, ChaseReeval.DESTINATION_AND_DURATION)

    wait(3.3)

    stopChasingVariable(eventPlayer.tPos)

    # Stage 4
    introStage1Players.remove(eventPlayer)

    eventPlayer.tPos = vect(26.97, 21.97, 47.25)
    eventPlayer.startCamera(eventPlayer.tPos, vect(-35.24, 11.71, -55.88), 0)
    chase(eventPlayer.tPos, vect(-33.71, 11.70, -53.29), duration=2.80, ChaseReeval.DESTINATION_AND_DURATION)

    wait(4.6)

    stopChasingVariable(eventPlayer.tPos)

    # Title view
    introStage2Players.append(eventPlayer)
    playEffect(eventPlayer, DynamicEffect.JUNKRAT_RIP_TIRE_EXPLOSION, null, vect(-35.24, 12.71, -55.88), 10)
    playEffect(eventPlayer, DynamicEffect.JUNKRAT_RIP_TIRE_EXPLOSION_SOUND, null, vect(-35.24, 12.71, -55.88), 80)

    wait(4)

    introStage2Players.remove(eventPlayer)

    eventPlayer.stopCamera()
    eventPlayer.enableHeroHud()
    eventPlayer.clearStatusEffect(Status.ROOTED)
    eventPlayer.setInvisibility(Invis.NONE)

    hudHeader(eventPlayer, "Inventory: {0}".format(eventPlayer.inventory), HudPosition.LEFT, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

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

def manageEquips():
    equipPlayers[Equip.HAS_ANY].remove(eventPlayer)
    equipPlayers[Equip.LITTLE_BUDDY].remove(eventPlayer)
    equipPlayers[Equip.SUNSCREEN].remove(eventPlayer)
    equipPlayers[Equip.SUNGLASES].remove(eventPlayer)
    equipPlayers[Equip.WINGS].remove(eventPlayer)

    if len(eventPlayer.equipped) > 0:
        equipPlayers[Equip.HAS_ANY].append(eventPlayer)
    if Equip.LITTLE_BUDDY in eventPlayer.equipped:
        equipPlayers[Equip.LITTLE_BUDDY].append(eventPlayer)
    if Equip.SUNSCREEN in eventPlayer.equipped:
        equipPlayers[Equip.SUNSCREEN].append(eventPlayer)
    if Equip.SUNGLASES in eventPlayer.equipped:
        equipPlayers[Equip.SUNGLASES].append(eventPlayer)
    if Equip.WINGS in eventPlayer.equipped:
        equipPlayers[Equip.WINGS].append(eventPlayer)

def manageAchievements():
    achievementPlayers[Achievement.MOST_WANTED].remove(eventPlayer)
    achievementPlayers[Achievement.INFRASIGHT].remove(eventPlayer)
    achievementPlayers[Achievement.PUZZLE_MASTER].remove(eventPlayer)
    achievementPlayers[Achievement.IN_A_HURRY].remove(eventPlayer)
    achievementPlayers[Achievement.ESCAPE_ARTIST].remove(eventPlayer)

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
    if Achievement.ESCAPE_ARTIST in eventPlayer.achievements:
        achievementPlayers[Achievement.ESCAPE_ARTIST].append(eventPlayer)

def playerInitialState():
    # Player state
    eventPlayer.pauseInteraction = false

    eventPlayer.junkPos = vect(-95.58, 12.17, -86.79)
    eventPlayer.junkFacing = vect(1, 0, 0)

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

    eventPlayer.smugglerItem = null

    eventPlayer.money = 0

    eventPlayer.achievements = []

    eventPlayer.inSunlight = false

    # Game state
    eventPlayer.tutorialFinished = false
    eventPlayer.wiresConnected = false
    eventPlayer.generatorOn = false
    eventPlayer.powerSwitched = false
    eventPlayer.lightsOn = false

    innerMinigameInitialState()
    eventPlayer.hasFinishedInnerMinigame = false

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

    eventPlayer.isMolePersonFriend = false

    eventPlayer.bruceTimer = 0

    eventPlayer.satsTuned = 0

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
    eventPlayer.tutGate1 = ["tutGate1", 0, vect(-100.32, 11.44, -90.75), 1.5, ["The lasers would slice you up if you tried to go through"], null, null, null, 1, ["Rusty key"], ["How does a key open a laser gate? You aren't one to think about it too hard"]]
    eventPlayer.tutGate2 = ["tutGate2", 0, vect(-92.97, 11.44, -92.29), 1.5, ["The lasers would slice you up if you tried to go through"], null, null, null, 1, ["Rusty key"], null]

    eventPlayer.innerWires = ["innerWires", 0, vect(-106.91, 12.44, -135.82), 0.4, ["The wires are sparking", "The wires are connected"], null, null, null, null, ["Extension cord"], ["You connect the wires"]]
    eventPlayer.innerBarrel2 = ["innerBarrel2", 0, vect(-103.58, 7.02, -120.15), 0.5, ["There's a little bit of petrol pooled in the bottom", "The barrel is now completely empty"], null, null, null, null, ["Empty petrol can"], ["You fill up the petrol can with with the last of the petrol"]]
    eventPlayer.innerGenerator = ["innerGenerator", 0, vect(-109.58, 13.83, -132.75), 2.5, ["The generator is cold and lifeless", "The generator hums with a dim energy"], null, null, null, null, ["Fuel filled petrol can"], ["You pour the petrol into the generator"]]

    eventPlayer.innerRadio = ["innerRadio", 0, vect(-90.05, 8.69, -103.28), 0.3, ["A radio to the outside. It seems to be missing a fiddly part though", "The radio is busted. Oops"], null, null, null, null, null, null]
    eventPlayer.innerWorkbench = ["innerWorkbench", 0, vect(-103.41, 8.67, -184.58), 1, ["A workbench with a number of tools left on it", "The workbench has outlived its usefulness"], null, null, null, null, ["Fiddly part"], ["This should help you reverse the polarity of the fiddly part"]]

    eventPlayer.innerToolbox2 = ["innerToolbox2", 0, vect(-103.00, 8.01, -182.63), 0.75, ["It's locked"], null, true, null, null, ["Vent key"], ["The toolbox unlocks. Inside you find some ancient sunscreen"]]

    eventPlayer.outerWorkbench = ["outerWorkbench", 0, vect(-56.45, 11.90, -60.51), 1, ["A workbench with a number of tools left on it", "The workbench has outlived its usefulness"], null, null, null, null, ["Red battery"], ["This should help you change the color of the battery"]]


    eventPlayer.outerBruce = ["outerBruce", 0, vect(-21.62, 7.48, -104.95), 1, null]
    eventPlayer.outerSmuggler = ["outerSmuggler", 0, vect(-19.06, 14.48, -88.07), 1, null]
    eventPlayer.outerBartender = ["outerBartender", 0, vect(-54.65, 2.73, -131.02), 1, null]
    eventPlayer.outerNotSmuggler = ["outerNotSmuggler", 0, vect(-35.02, 2.48, -126.33), 1, null]

    eventPlayer.outsideHose = ["outsideHose", 0, vect(-31.21, 6.36, -27.83), 0.7, ["The hose leads down from the water tower", "You don't need any more water"], null, null, null, null, ["Empty petrol can"], ["You fill up the can with murky water"]]
    eventPlayer.outsideSat1 = ["outsideSat1", 0, vect(25.774, 16.251, -90.842), 1, ["The dish isn't tuned", "The dish is tuned"], null, null, null, null, ["Tuned satellite tuner"], ["You tune the antenna"]]
    eventPlayer.outsideSat2 = ["outsideSat2", 0, vect(12.000, 17.647, -88.850), 1, ["The dish isn't tuned", "The dish is tuned"], null, null, null, null, ["Tuned satellite tuner"], ["You tune the antenna"]]
    eventPlayer.outsideSat3 = ["outsideSat3", 0, vect(-1.572, 16.131, -58.995), 1, ["The dish isn't tuned", "The dish is tuned"], null, null, null, null, ["Tuned satellite tuner"], ["You tune the antenna"]]
    eventPlayer.outsideSat4 = ["outsideSat4", 0, vect(6.139, 17.041, -44.789), 1, ["The dish isn't tuned", "The dish is tuned"], null, null, null, null, ["Tuned satellite tuner"], ["You tune the antenna"]]
    eventPlayer.outsideSmuggler = ["outsideSmuggler", 0, vect(-44.52, 5.49, -49.63), 1, null]
    eventPlayer.outsideMolePerson = ["outsideMolePerson", 0, vect(-51.97, 6.14, -3.03), 2, null]

    eventPlayer.itemPoints = [
        # tutorial room
        ["tutSafe1", 0, vect(-104.92, 12.06, -84.28), 1.2, ["All that's inside are a few dusty cobwebs"], null, true],
        ["tutSafe2", 0, vect(-100.95, 11.28, -80.59), 0.7, ["This safe is rusted shut, despite having gold hinges"], null, true],
        ["tutSafe3", 0, vect(-103.16, 11.95, -76.61), 1, ["The box is buried under a mound of gold and can't be opened"], null, true],
        ["tutSafe4", 0, vect(-89.28, 12.44, -72.22), 1.2, ["The door of the safe is too heavy to lift"], null, true],
        ["tutSafe5", 0, vect(-88.78, 11.51, -90.72), 0.7, ["The door squeaks open and you find a rusty key inside"], "Rusty key", true],
        ["tutGold", 0, vect(-95.60, 11.38, -86.96), 1.5, ["A giant safe filled with gold, perfect for sleeping in"]],

        # lights on section
        ["innerFridge", 0, vect(-110.04, 6.97, -111.51), 1.1, ["The fridge is full of fish heads and half eaten Chinese food"], null, true],
        ["innerChest1", 0, vect(-114.91, 7.07, -124.08), 1.2, ["Who kept an empty petrol can in here?"], "Empty petrol can", true],
        ["innerLocker1", 0, vect(-112.76, 7.55, -134.80), 1.2, ["locker 1"], null, true],
        ["innerLocker2", 0, vect(-113.80, 7.55, -139.10), 1.2, ["locker 2"], null, true],
        ["innerLocker3", 0, vect(-112.58, 7.55, -141.24), 1.2, ["locker 3"], null, true],
        ["innerLocker4", 0, vect(-108.08, 7.55, -142.79), 1.2, ["There's an old extension cord hidden in the back"], "Extension cord", true],
        ["innerLocker5", 0, vect(-106.71, 7.55, -141.16), 1.2, ["You don't even want to think about whose swimsuit that is"], null, true],

        ["innerBarrel1", 0, vect(-113.43, 7.02, -116.14), 0.5, ["Barrel 1"], null, true],
        ["innerBarrel3", 0, vect(-105.32, 12.79, -132.71), 0.5, ["Barrel 3"], null, true],

        ["innerSwitch1", 0, vect(-111.46, 14.145, -137.47), 0.05, null],
        ["innerSwitch2", 0, vect(-111.46, 14.071, -137.47), 0.05, null],
        ["innerSwitch3", 0, vect(-111.46, 13.994, -137.47), 0.05, null],
        ["innerSwitch4", 0, vect(-111.46, 13.914, -137.47), 0.05, null],
        ["innerSwitch5", 0, vect(-111.46, 13.835, -137.47), 0.05, null],
        ["innerPowerBox", 0, vect(-111.73, 14.04, -137.34), 0.5, null],

        # larger inner section
        ["innerThrone", 0, vect(-88.94, 8.40, -102.99), 0.75, ["The queen's throne... oh how you want to sit on it"]],

        ["innerChest2", 0, vect(-101.16, 8.12, -198.06), 1.2, ["There's a red battery inside"], "Red battery", true],
        ["innerToolbox1", 0, vect(-103.25, 8.92, -182.63), 0.75, ["There's a note: \"Threw the key in the vent. As long as the vents are running, no one should be able to grab it.\""], null, true],
        ["innerSmallToolbox1", 0, vect(-102.65, 9.06, -181.25), 0.5, ["Someone just left a fiddly part in the toolbox? It must be your lucky day"], "Fiddly part", true],
        ["innerTireRack", 0, vect(-87.96, 8.63, -201.60), 1.8, ["Why are there rubber tires when all the cars hover?"]],

        ["innerBrokenMech1", 0, vect(-88.35, 8.26, -142.03), 2, ["This mech seems to be missing a limb. You sympathize with it"]],
        ["innerBrokenMech2", 0, vect(-75.42, 8.52, -146.11), 2, ["A broken mech 2"]],
        ["innerMech1", 0, vect(-90.47, 10.09, -177.75), 2, ["A fully working mech 1"]],
        ["innerMech2", 0, vect(-94.87, 10.11, -178.01), 2, ["A fully working mech 2"]],

        ["innerMinigameControl1", 0, vect(-103.45, 8.89, -184.36), 0.1, null],
        ["innerMinigameControl2", 0, vect(-103.50, 8.89, -184.63), 0.1, null],
        ["innerMinigameSkip", 0, INNER_MINIGAME_2D_TO_3D(vect(1.48, 0.73, 0)), 0.05, null],

        ["innerSunglasses", 0, vect(-88.04, 13.37, -158.22), 1, ["You find some tattered sunglasses hidden in the corner", "You've already scoured this area"]],

        ["innerValve1", 0, vect(-85.83, 8.43, -178.64), 0.5, ["You twist the valve shut", "The valve is already closed"]],
        ["innerValve2", 0, vect(-54.84, 9.57, -143.66), 0.5, ["You twist the valve shut", "The valve is already closed"]],
        ["innerValve3", 0, vect(-53.58, 9.91, -122.34), 0.5, ["You twist the valve shut", "The valve is already closed"]],

        ["innerVent1", 0, vect(-108.61, 10.46, -108.17), 1, ["You don't see anything in here"]],
        ["innerVent2", 0, vect(-84.87, 11.34, -186.75), 1, ["You don't see anything in here"]],
        ["innerVent3", 0, vect(-54.90, 10.74, -125.39), 1, null],
        ["innerVent4", 0, vect(-75.87, 14.17, -123.53), 2, ["You don't see anything in here"]],
        ["innerVent5", 0, vect(-69.87, 15.81, -107.26), 1, ["You don't see anything in here"]],
        ["innerVent6", 0, vect(-94.74, 13.59, -177.53), 1, ["You don't see anything in here"]],
        ["innerVent7", 0, vect(-86.38, 14.14, -180.01), 1.8, ["You don't see anything in here"]],


        # courtyard area
        ["outerIceBox", 0, vect(-50.77, 2.49, -126.77), 1, ["ice box"], null, true],
        ["outerSmallToolbox1", 0, vect(-11.03, 8.29, -103.06), 0.5, ["small toolbox 1"], null, true],
        ["outerToolbox1", 0, vect(-61.25, 11.55, -75.41), 0.75, ["toolbox 1"], null, true],
        ["outerToolbox2", 0, vect(-9.54, 8.40, -104.89), 0.75, ["toolbox 2"], null, true],
        ["outerToolbox3", 0, vect(-10.33, 7.33, -102.96), 0.75, ["toolbox 3"], null, true],
        ["outerRadio", 0, vect(-10.46, 8.35, -105.80), 0.3, ["radio"]],
        ["outerMic", 0, vect(-30.95, 3.80, -135.05), 0.5, null],

        ["outerCart", 0, vect(-41.66, 6.20, -66.89), 3, ["cart"]],

        ["outerPoster1", 0, vect(-64.74, 8.68, -102.96), 0.8, ["A grossly unfair characterization"], null, null, true],
        ["outerPoster2", 0, vect(-60.39, 14.28, -88.06), 0.5, ["poster2"], null, null, true],
        ["outerPoster3", 0, vect(-48.70, 8.39, -95.52), 0.8, ["poster3"], null, null, true],
        ["outerPoster4", 0, vect(-45.22, 8.42, -112.92), 0.5, ["poster4"], null, null, true],
        ["outerPoster5", 0, vect(-42.93, 8.67, -116.01), 0.5, ["poster5"], null, null, true],
        ["outerPoster6", 0, vect(-26.17, 14.43, -112.75), 0.5, ["poster6"], null, null, true],
        ["outerPoster7", 0, vect(-20.13, 8.15, -95.48), 0.7, ["poster7"], null, null, true],
        ["outerPoster8", 0, vect(-32.28, 7.78, -94.74), 0.5, ["poster8"], null, null, true],
        ["outerPoster9", 0, vect(-31.35, 7.44, -85.96), 1.1, ["poster9"], null, null, true],
        ["outerPoster10", 0, vect(-44.65, 6.38, -76.55), 0.7, ["poster10"], null, null, true],
        ["outerPoster11", 0, vect(-35.80, 5.70, -70.76), 1, ["poster11"], null, null, true],
        ["outerPoster12", 0, vect(-44.66, 6.73, -60.23), 1.1, ["poster12"], null, null, true],
        ["outerPoster13", 0, vect(-33.01, 5.96, -63.99), 0.7, ["poster13"], null, null, true],
        ["outerPoster14", 0, vect(-54.26, 5.98, -47.88), 0.7, ["poster14"], null, null, true],

        ["outerBinoculars", 0, vect(-36.64, 14.02, -59.19), 0.3, ["binoculars"]],

        ["outerMinigameDot1", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17 * 3, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot2", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.62, 0.08 + 0.17 * 2, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot3", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.82, 0.08 + 0.17 * 2, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot4", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.52, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot5", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot6", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.92, 0.08 + 0.17, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot7", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.42, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot8", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.62, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot9", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.82, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameDot10", 0, OUTER_MINIGAME_2D_TO_3D(vect(1.02, 0.08, 0)), OUTER_MINIGAME_BALL_SIZE, null],
        ["outerMinigameRotate1", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.72, 0.08 + 0.17 * 7 / 3, 0)), 0.08, null],
        ["outerMinigameRotate2", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.52, 0.08 + 0.17 / 3, 0)), 0.08, null],
        ["outerMinigameRotate3", 0, OUTER_MINIGAME_2D_TO_3D(vect(0.92, 0.08 + 0.17 / 3, 0)), 0.08, null],
        ["outerMinigameSkip", 0, OUTER_MINIGAME_2D_TO_3D(vect(1.15, 0.59, 0)), 0.05, null],

        ["outerDoor21", 0, vect(-50.47, 13.63, -84.74), 1.1, null],
        ["outerDoor22", 0, vect(-54.41, 13.63, -84.09), 1.1, null],
        ["outerDoor23", 0, vect(-59.72, 13.63, -85.31), 1.1, null],
        ["outerDoor24", 0, vect(-48.46, 13.63, -90.79), 1.1, null],
        ["outerDoor25", 0, vect(-42.10, 14.63, -94.75), 1.1, null],


        # barn area
        ["barnRadio", 0, vect(69.46, 15.15, -86.83), 0.7, ["That idiot managed to blow up the only working radio"]],
        ["barnTvPanel", 0, vect(70.40, 15.44, -82.28), 0.4, ["You don't need to change the TV channel right now"]],
        ["barnPachimari", 0, vect(69.81, 10.58, -80.19), 1.2, ["Despite your love for them, you were never any good at these things"]],
        ["barnBike", 0, vect(54.56, 10.65, -78.11), 2.5, ["bike"]],
        ["barnFuelMachine", 0, vect(69.01, 10.34, -84.15), 1.2, ["fuel machine"], null, true],
        ["barnFridge", 0, vect(66.91, 10.37, -67.64), 1, ["fridge"], null, true],
        ["barnTireRack", 0, vect(44.07, 10.12, -88.71), 1.5, ["This rack of hover pads is entirely unremarkable"], null, null, true],
        ["barnPlan", 0, vect(44.03, 11.11, -71.35), 1.5, ["Things didn't to according to plan"], null, null, true],

        ["barnToolbox1", 0, vect(49.62, 10.55, -75.25), 0.75, ["toolbox 1"], null, true],
        ["barnToolbox2", 0, vect(50.55, 9.42, -75.90), 0.75, ["toolbox 2"], null, true],
        ["barnSmallToolbox1", 0, vect(49.20, 10.27, -79.17), 0.5, ["small toolbox 1"], null, true],
        ["barnSafe1", 0, vect(60.60, 10.01, -65.34), 1, ["safe 1"], null, true, true],
        ["barnSafe2", 0, vect(60.52, 9.50, -63.60), 0.8, ["You pick up your little buddy and place him carefully in your bag"], null, true],
        ["barnSafe3", 0, vect(56.13, 9.74, -62.70), 0.7, ["safe 3"], null, true, true],
        ["barnEmptyShelf", 0, vect(50.05, 10.56, -63.46), 2, ["Times have been rough lately"], null, true, true],

        ["barnPaperClue1", 0, vect(58.30, 9, -93.83), 0.3, null],
        ["barnPaperClue2", 0, vect(42.25, 16, -71.88), 0.3, null],

        ["barnSwitch1", 0, vect(56.48, 10.655, -66.584), 0.05, null],
        ["barnSwitch2", 0, vect(56.48, 10.581, -66.584), 0.05, null],
        ["barnSwitch3", 0, vect(56.48, 10.504, -66.584), 0.05, null],
        ["barnSwitch4", 0, vect(56.48, 10.424, -66.584), 0.05, null],
        ["barnSwitch5", 0, vect(56.48, 10.345, -66.584), 0.05, null],
        ["barnCodePanel", 0, vect(56.55, 10.50, -66.74), 0.5, ["This opens your secret stash, if only you could remember the code"]],


        # larger outside area
        eventPlayer.outsideHose, # placed here for priority reasons 

        ["outsideJunkWorkbench", 0, vect(31.57, 10.71, -95.93), 1.2, ["outsideJunkWorkbench"]],
        ["outsideSafe", 0, vect(21.24, 10.90, -88.37), 0.7, ["outsideSafe"], null, true],
        ["outsideIceBox", 0, vect(-32.99, 5.36, -29.36), 1, ["outsideIceBox"], null, true, true],
        ["outsideFridge1", 0, vect(20.48, 11.05, -95.08), 1, ["There's a map with a point marked on it"]],
        ["outsideHose", 0, vect(-31.21, 6.36, -27.83), 0.7, ["water tower hose"]],
        ["outsideFridge2", 0, vect(-5.68, 13.51, -74.65), 1.2, ["outsideFridge2"], null, true],
        ["outsideFridge3", 0, vect(-31.79, 5.62, -28.84), 0.8, ["outsideFridge3"], null, true, true],
        ["outsideFridge4", 0, vect(-31.72, 5.57, -30.10), 0.8, ["outsideFridge4"], null, true, true],
        ["outsideToolbox1", 0, vect(-6.67, 8.55, -77.17), 0.7, ["outsideToolbox1"], null, true],
        ["outsideToolbox2", 0, vect(-6.55, 7.60, -77.18), 0.7, ["Satellite tuner"], null, true],
        ["outsideSmallToolbox", 0, vect(24.28, 9.26, -64.30), 0.5, ["outsideSmallToolbox"], null, true],
        ["outsideChest1", 0, vect(19.26, 8.73, -55.36), 1.2, ["outsideChest1"], null, true],
        ["outsideChest2", 0, vect(-7.98, 8.35, -47.93), 1.2, ["outsideChest2"], null, true],
        ["outsideChest3", 0, vect(-7.98, 6.58, -47.93), 1.2, ["outsideChest3"], null, true],
        ["outsideChest4", 0, vect(-35.12, 5.22, -43.65), 1.2, ["outsideChest4"], null, true],
        ["outsideChest5", 0, vect(-50.83, 4.92, -16.62), 1.2, ["outsideChest5"], null, true],
        ["outsideChest6", 0, vect(-50.56, 5.21, -4.09), 1.2, ["outsideChest6"], null, true],

        ["outsidePoster1", 0, vect(-30.90, 6.14, -60.22), 0.8, ["poster 1"], null, null, true],
        ["outsidePoster2", 0, vect(-23.46, 6.70, -66.49), 0.8, ["poster 2"], null, null, true],


        # item apply points
        eventPlayer.tutGate1,
        eventPlayer.tutGate2,

        eventPlayer.innerWires,
        eventPlayer.innerBarrel2,
        eventPlayer.innerGenerator,
        eventPlayer.innerRadio,
        eventPlayer.innerWorkbench,
        eventPlayer.innerToolbox2,

        eventPlayer.outerBruce,
        eventPlayer.outerSmuggler,
        eventPlayer.outerBartender,
        eventPlayer.outerNotSmuggler,
        eventPlayer.outerWorkbench,

        eventPlayer.outsideSmuggler,
        eventPlayer.outsideMolePerson,
        eventPlayer.outsideSat1,
        eventPlayer.outsideSat2,
        eventPlayer.outsideSat3,
        eventPlayer.outsideSat4,
    ]

    eventPlayer.itemIds = [elem[Item.ID] for elem in eventPlayer.itemPoints]

    # Other state setup
    introStage1Players.remove(eventPlayer)
    introStage2Players.remove(eventPlayer)

    manageEquips()
    manageAchievements()

    playersInDark.remove(eventPlayer)
    playersInDark.append(eventPlayer)

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

    satUntunedPlayers[0].remove(eventPlayer)
    satUntunedPlayers[1].remove(eventPlayer)
    satUntunedPlayers[2].remove(eventPlayer)
    satUntunedPlayers[3].remove(eventPlayer)
    satTunedPlayers[0].remove(eventPlayer)
    satTunedPlayers[1].remove(eventPlayer)
    satTunedPlayers[2].remove(eventPlayer)
    satTunedPlayers[3].remove(eventPlayer)

    eventPlayer.startForcingHero(Hero.JUNKRAT)
    eventPlayer.teleport(eventPlayer.junkPos)
    eventPlayer.setFacing(eventPlayer.junkFacing, Relativity.TO_WORLD)
    wait(RACE_CONDITION_DELAY)
    eventPlayer.isJunk = true

rule "On player join":
    @Event playerJoined
    @Team 1

    # async(showIntro, AsyncBehavior.NOOP)
    hudHeader(eventPlayer, "Inventory: {0}".format(eventPlayer.inventory), HudPosition.LEFT, 100, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    playerInitialState()

    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INF)
    eventPlayer.setInvisibility(Invis.ENEMIES)
    eventPlayer.disableGamemodeHud()
    # eventPlayer.disableScoreboard()
    eventPlayer.disableGamemodeInWorldUi()
    eventPlayer.disableMessages()



# PASSIVE ONGOING    

rule "Update junk position and direction":
    @Event eachPlayer
    @Condition eventPlayer.isJunk

    eventPlayer.junkPos = eventPlayer.getPosition()
    eventPlayer.junkFacing = eventPlayer.getFacingDirection()
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

rule "Update hog position and direction":
    @Event eachPlayer
    @Condition eventPlayer.isHog

    eventPlayer.hogPos = eventPlayer.getPosition()
    eventPlayer.hogFacing = eventPlayer.getFacingDirection()
    wait(0.016, Wait.ABORT_WHEN_FALSE)
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

rule "Update is in sunlight":
    @Event eachPlayer

    eventPlayer.inSunlight = (isInLoS(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + vect(0, 100, 0), BarrierLos.PASS_THROUGH_BARRIERS) or \
        isInLoS(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + vect(SUNLIGHT_ANGLE, 100, SUNLIGHT_ANGLE), BarrierLos.PASS_THROUGH_BARRIERS) or \
        isInLoS(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + vect(SUNLIGHT_ANGLE, 100, -SUNLIGHT_ANGLE), BarrierLos.PASS_THROUGH_BARRIERS) or \
        isInLoS(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + vect(-SUNLIGHT_ANGLE, 100, SUNLIGHT_ANGLE), BarrierLos.PASS_THROUGH_BARRIERS) or \
        isInLoS(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + vect(-SUNLIGHT_ANGLE, 100, -SUNLIGHT_ANGLE), BarrierLos.PASS_THROUGH_BARRIERS)) and \
        not (eventPlayer.getEyePosition().x < -53 and eventPlayer.getEyePosition().z < -113)

    wait()
    goto RULE_START

# requires that all ncps are at least 10m apart
rule "Hide npc text":
    @Event eachPlayer
    @Condition distance(eventPlayer, BRUCE_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, INSIDE_SMUGGLER_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, OUTSIDE_SMUGGLER_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, BARTENDER_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, NOT_SMUGGLER_TEXT_LOCATION) > 5
    @Condition distance(eventPlayer, vect(-49.37, 13.63, -86.90)) > 12 or eventPlayer.getPosition().y < 12.40
    @Condition distance(eventPlayer, MOLE_PERSON_TEXT_LOCATION) > 16

    popTextDeleteQueue()



# STATE CHANGES

rule "Poster achievement":
    @Event eachPlayer
    @Condition len(eventPlayer.postersFound) == 16

    bigMessage(eventPlayer, "Achievement get! Most wanted: find all the posters of you")
    eventPlayer.achievements.append(Achievement.MOST_WANTED)
    manageAchievements()

rule "Lights on check":
    @Event eachPlayer
    @Condition eventPlayer.wiresConnected and eventPlayer.generatorOn and eventPlayer.powerSwitched

    eventPlayer.lightsOn = true
    playersInDark.remove(eventPlayer)
    playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATING_SOUND, null, eventPlayer.getPosition() - eventPlayer.getFacingDirection() * 0.1, 100)
    INCREMENT_STATE("innerSwitch1")
    INCREMENT_STATE("innerSwitch2")
    INCREMENT_STATE("innerSwitch3")
    INCREMENT_STATE("innerSwitch4")
    INCREMENT_STATE("innerSwitch5")

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
    SET_STATE("innerWorkbench", 1)
    eventPlayer.inventory.remove("Fiddly part")
    eventPlayer.inventory = "Reverse polarity fiddly part".concat(eventPlayer.inventory)
    smallMessage(eventPlayer, "You manager to reverse the polarity of the fiddly part")

rule "Inner workbench minigame stop":
    @Event eachPlayer
    @Condition eventPlayer.isDoingInnerMinigame and distance(eventPlayer, eventPlayer.innerWorkbench[Item.POINT]) > 3

    innerMinigameInitialState()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    popEffectDeleteQueue()
    innerMinigamePlayers.remove(eventPlayer)

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
    SET_STATE("outerWorkbench", 1)
    eventPlayer.inventory.remove("Red battery")
    eventPlayer.inventory = "Black battery".concat(eventPlayer.inventory)
    smallMessage(eventPlayer, "You manager to change the color of the battery")

    if eventPlayer.outerMinigameMovesMade <= 5:
        wait(3) # wait for small message to disappear
        bigMessage(eventPlayer, "Achievement get! Puzzle master: solve the color puzzle in 5 moves")
        eventPlayer.achievements.append(Achievement.PUZZLE_MASTER)
        manageAchievements()

rule "Outer workbench minigame stop":
    @Event eachPlayer
    @Condition eventPlayer.isDoingOuterMinigame and distance(eventPlayer, eventPlayer.outerWorkbench[Item.POINT]) > 3

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
    outerMinigamePlayers.remove(eventPlayer)
    wait(RACE_CONDITION_DELAY) # prevents flashes
    outerMinigameInitialState()

# Radio conversation
def doInnerRadioConversation():
    eventPlayer.pauseInteraction = true
    smallMessage(eventPlayer, "You say something")
    wait(4)
    smallMessage(eventPlayer, "Thing go boom")
    playEffect(eventPlayer, DynamicEffect.JUNKRAT_RIP_TIRE_EXPLOSION, null, eventPlayer.innerRadio[Item.POINT], 100)
    playEffect(eventPlayer, DynamicEffect.JUNKRAT_RIP_TIRE_EXPLOSION_SOUND, null, eventPlayer.innerRadio[Item.POINT], 100)
    radioSmokePlayers.append(eventPlayer)
    wait(3)
    smallMessage(eventPlayer, "Press F to be the other guy")

    eventPlayer.canBeTheOtherGuy = true

    eventPlayer.pauseInteraction = false

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

    SET_STATE("outerBruce", 9)

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

    manageEquips()

    smallMessage(eventPlayer, "You are now the other guy")


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
#!define GIVE_ITEM(item) eventPlayer.inventory = item.concat(eventPlayer.inventory)

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
    elif eventPlayer.tValue[Item.MESSAGE]:
        playNoItem()
        smallMessage(eventPlayer, NOTHING_LEFT_MESSAGE)

    # special interactions

    if eventPlayer.isJunk:
        if eventPlayer.wiresConnected and eventPlayer.generatorOn and not eventPlayer.lightsOn:
            if eventPlayer.tValue[Item.ID] == "innerSwitch1":
                TOGGLE_POWER_SWITCH(4)
                TOGGLE_POWER_SWITCH(0)
                TOGGLE_POWER_SWITCH(1)
                makeSwitchNoise()
                checkPowerPanel()
            elif eventPlayer.tValue[Item.ID] == "innerSwitch2":
                TOGGLE_POWER_SWITCH(0)
                TOGGLE_POWER_SWITCH(1)
                TOGGLE_POWER_SWITCH(2)
                makeSwitchNoise()
                checkPowerPanel()
            elif eventPlayer.tValue[Item.ID] == "innerSwitch3":
                TOGGLE_POWER_SWITCH(1)
                TOGGLE_POWER_SWITCH(2)
                TOGGLE_POWER_SWITCH(3)
                makeSwitchNoise()
                checkPowerPanel()
            elif eventPlayer.tValue[Item.ID] == "innerSwitch4":
                TOGGLE_POWER_SWITCH(2)
                TOGGLE_POWER_SWITCH(3)
                TOGGLE_POWER_SWITCH(4)
                makeSwitchNoise()
                checkPowerPanel()
            elif eventPlayer.tValue[Item.ID] == "innerSwitch5":
                TOGGLE_POWER_SWITCH(3)
                TOGGLE_POWER_SWITCH(4)
                TOGGLE_POWER_SWITCH(0)
                makeSwitchNoise()
                checkPowerPanel()

        if eventPlayer.tValue[Item.ID] == "innerPowerBox":
            if not eventPlayer.wiresConnected or not eventPlayer.generatorOn:
                if eventPlayer.tValue[Item.STATE] == 0:
                    smallMessage(eventPlayer, "This is the power switching box for the whole area")
                    eventPlayer.tValue[Item.STATE]++
                    eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
                elif eventPlayer.tValue[Item.STATE] == 1:
                    smallMessage(eventPlayer, "Maybe if you get the generator running you can turn the lights on")
                    eventPlayer.tValue[Item.STATE]++
                    eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
                else:
                    smallMessage(eventPlayer, "There's no power going to the box")
            elif not eventPlayer.powerSwitched:
                smallMessage(eventPlayer, "One of the panels is broken, just like everything else in this place")
            else:
                smallMessage(eventPlayer, "The pretty green lights make you giddy")
        elif eventPlayer.tValue[Item.ID] == "innerMinigameControl1" and eventPlayer.isDoingInnerMinigame and not eventPlayer.hasFinishedInnerMinigame:
            eventPlayer.isHoldingInnerMinigameControl1 = true
            chase(eventPlayer.innerMinigameValue1, INF, rate=1, ChaseReeval.NONE)
            chase(eventPlayer.innerMinigameValue2, INF, rate=1.8, ChaseReeval.NONE)
        elif eventPlayer.tValue[Item.ID] == "innerMinigameControl2" and eventPlayer.isDoingInnerMinigame and not eventPlayer.hasFinishedInnerMinigame:
            eventPlayer.isHoldingInnerMinigameControl2 = true
            chase(eventPlayer.innerMinigameValue1, INF, rate=1.8, ChaseReeval.NONE)
            chase(eventPlayer.innerMinigameValue2, INF, rate=1, ChaseReeval.NONE)
        elif eventPlayer.tValue[Item.ID] == "innerMinigameSkip" and eventPlayer.isDoingInnerMinigame and not eventPlayer.hasFinishedInnerMinigame:
            eventPlayer.innerMinigameValue1 = 3 * PI / 2
            eventPlayer.innerMinigameValue2 = PI / 6
        elif eventPlayer.tValue[Item.ID] == "innerSunglasses":
            if Equip.SUNGLASES not in eventPlayer.equipped:
                INCREMENT_STATE("innerSunglasses")
                eventPlayer.hasSunglasses = true
                eventPlayer.equipped.append(Equip.SUNGLASES)
                manageEquips()
                if not eventPlayer.outsideMapFound:
                    wait(3) # wait for small message to disappear
                    bigMessage(eventPlayer, "Achievement get! Infrasight: find the sunglasses without using the map")
                    eventPlayer.achievements.append(Achievement.INFRASIGHT)
                    manageAchievements()
        elif eventPlayer.tValue[Item.STATE] == 0 and (eventPlayer.tValue[Item.ID] == "innerValve1" or eventPlayer.tValue[Item.ID] == "innerValve2" or eventPlayer.tValue[Item.ID] == "innerValve3"):
            eventPlayer.tValue[Item.STATE]++
            eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
            eventPlayer.numVentsClosed++
            playEffect(eventPlayer, DynamicEffect.DOOMFIST_RISING_UPPERCUT_IMPACT_SOUND, null, eventPlayer.tValue[Item.POINT], 100)
        elif eventPlayer.tValue[Item.ID] == "innerVent3":
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
        elif eventPlayer.tValue[Item.ID] == "outerBruce":
            if eventPlayer.tValue[Item.STATE] == 0:
                CREATE_TEXT("You want me to help you? I don't even know who you are.", BRUCE_TEXT_LOCATION)
            elif eventPlayer.tValue[Item.STATE] == 1:
                CREATE_TEXT("Since you're a friend of Roadhog, I guess I can help you out.\nI'll need you to bring me three things though:\n- a black battery\n- some purified water\n- and a bottle of strong alcohol.", BRUCE_TEXT_LOCATION)
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
        elif eventPlayer.tValue[Item.ID] == "outerSmuggler":
            if not eventPlayer.canUtilizeSmuggler:
                CREATE_TEXT("Welcome to Tracer's Delivery Service!\nWe deliver anything to anyone anywhere!\nLifetime membership is only {0} dollars!".format(SMUGGLER_COST), INSIDE_SMUGGLER_TEXT_LOCATION)
            else:
                if eventPlayer.smugglerItem:
                    CREATE_TEXT("Looks like we have something for you!", INSIDE_SMUGGLER_TEXT_LOCATION)
                    eventPlayer.tText = eventPlayer.smugglerItem
                    smallMessage(eventPlayer, "Received {0}".format(eventPlayer.tText))
                    GIVE_ITEM(eventPlayer.smugglerItem)
                    eventPlayer.smugglerItem = null
                else:
                    CREATE_TEXT("Sorry, nothing for you", INSIDE_SMUGGLER_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == "outerBartender":
            if eventPlayer.tValue[Item.STATE] == 0:
                CREATE_TEXT("Drinks round here cost {0} bucks. But just for you,\nI'll make an exception and only charge you {1}.".format(ALCOHOL_COST / 2, ALCOHOL_COST), BARTENDER_TEXT_LOCATION)
            else:
                CREATE_TEXT("You've cleaned me right out of hard liquor.", BARTENDER_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.ID] == "outerNotSmuggler":
            if eventPlayer.tValue[Item.STATE] == 0:
                CREATE_TEXT("Dance for me, monkey.", NOT_SMUGGLER_TEXT_LOCATION)
            elif eventPlayer.tValue[Item.STATE] == 1:
                CREATE_TEXT("Alright, you've earned your pay.", NOT_SMUGGLER_TEXT_LOCATION)
                GIVE_ITEM("{0} dollars".format(ALCOHOL_COST + SMUGGLER_COST))
                eventPlayer.money = ALCOHOL_COST + SMUGGLER_COST
                eventPlayer.tValue[Item.STATE]++
                SAVE_STATE(eventPlayer.tValue)
            else:
                CREATE_TEXT("Hey, I already paid you.", NOT_SMUGGLER_TEXT_LOCATION)
        elif strContains(eventPlayer.tValue[Item.ID], "outerMinigame") and eventPlayer.isDoingOuterMinigame and not eventPlayer.hasFinishedOuterMinigame:
            eventPlayer.outerMinigameMovesMade++
            if eventPlayer.tValue[Item.ID] == "outerMinigameDot1":
                OUTER_MINIGAME_TOGGLE(1)
                OUTER_MINIGAME_TOGGLE(2)
                OUTER_MINIGAME_TOGGLE(3)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot2":
                OUTER_MINIGAME_TOGGLE(1)
                OUTER_MINIGAME_TOGGLE(2)
                OUTER_MINIGAME_TOGGLE(3)
                OUTER_MINIGAME_TOGGLE(4)
                OUTER_MINIGAME_TOGGLE(5)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot3":
                OUTER_MINIGAME_TOGGLE(1)
                OUTER_MINIGAME_TOGGLE(2)
                OUTER_MINIGAME_TOGGLE(3)
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(6)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot4":
                OUTER_MINIGAME_TOGGLE(2)
                OUTER_MINIGAME_TOGGLE(4)
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(7)
                OUTER_MINIGAME_TOGGLE(8)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot5":
                playEffect(eventPlayer, DynamicEffect.EXPLOSION_SOUND, null, eventPlayer, 30)
                eventPlayer.outerMinigameMovesMade--
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot6":
                OUTER_MINIGAME_TOGGLE(3)
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(6)
                OUTER_MINIGAME_TOGGLE(9)
                OUTER_MINIGAME_TOGGLE(10)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot7":
                OUTER_MINIGAME_TOGGLE(4)
                OUTER_MINIGAME_TOGGLE(7)
                OUTER_MINIGAME_TOGGLE(8)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot8":
                OUTER_MINIGAME_TOGGLE(4)
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(7)
                OUTER_MINIGAME_TOGGLE(8)
                OUTER_MINIGAME_TOGGLE(9)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot9":
                OUTER_MINIGAME_TOGGLE(5)
                OUTER_MINIGAME_TOGGLE(6)
                OUTER_MINIGAME_TOGGLE(8)
                OUTER_MINIGAME_TOGGLE(9)
                OUTER_MINIGAME_TOGGLE(10)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameDot10":
                OUTER_MINIGAME_TOGGLE(6)
                OUTER_MINIGAME_TOGGLE(9)
                OUTER_MINIGAME_TOGGLE(10)
            elif eventPlayer.tValue[Item.ID] == "outerMinigameRotate1":
                eventPlayer.tMinigame = eventPlayer.outerMinigameState[1]
                eventPlayer.outerMinigameState[1] = eventPlayer.outerMinigameState[2]
                eventPlayer.outerMinigameState[2] = eventPlayer.outerMinigameState[3]
                eventPlayer.outerMinigameState[3] = eventPlayer.tMinigame
            elif eventPlayer.tValue[Item.ID] == "outerMinigameRotate2":
                eventPlayer.tMinigame = eventPlayer.outerMinigameState[4]
                eventPlayer.outerMinigameState[4] = eventPlayer.outerMinigameState[7]
                eventPlayer.outerMinigameState[7] = eventPlayer.outerMinigameState[8]
                eventPlayer.outerMinigameState[8] = eventPlayer.tMinigame
            elif eventPlayer.tValue[Item.ID] == "outerMinigameRotate3":
                eventPlayer.tMinigame = eventPlayer.outerMinigameState[6]
                eventPlayer.outerMinigameState[6] = eventPlayer.outerMinigameState[9]
                eventPlayer.outerMinigameState[9] = eventPlayer.outerMinigameState[10]
                eventPlayer.outerMinigameState[10] = eventPlayer.tMinigame
            elif eventPlayer.tValue[Item.ID] == "outerMinigameSkip":
                eventPlayer.outerMinigameState = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                eventPlayer.outerMinigameMovesMade = INF
            else:
                eventPlayer.outerMinigameMovesMade--
        elif eventPlayer.tValue[Item.ID] == "outerMic":
            if eventPlayer.tValue[Item.STATE] == 0:
                smallMessage(eventPlayer, "You make a couple jokes")
                eventPlayer.tValue[Item.STATE]++
                eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue

                eventPlayer.tValue = GET_ITEM_ENTRY("outerNotSmuggler")
                eventPlayer.tValue[Item.STATE]++
                SAVE_STATE(eventPlayer.tValue)
            else:
                smallMessage(eventPlayer, "You're done with comedy for today")
        elif strContains(eventPlayer.tValue[Item.ID], "outerDoor"):
            if Equip.WINGS not in eventPlayer.equipped:
                CREATE_TEXT("'ere, 'oo are you?", eventPlayer.tValue[Item.POINT] + vect(0, 0.6, 0))
            else:
                if eventPlayer.tValue[Item.ID] == "outerDoor21":
                    pass

    if eventPlayer.isHog:
        if eventPlayer.tValue[Item.ID] == "barnSwitch1":
            makeSwitchNoise()
            ENTER_BARN_DIGIT(1)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == "barnSwitch2":
            makeSwitchNoise()
            ENTER_BARN_DIGIT(2)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == "barnSwitch3":
            makeSwitchNoise()
            ENTER_BARN_DIGIT(3)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == "barnSwitch4":
            makeSwitchNoise()
            ENTER_BARN_DIGIT(4)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == "barnSwitch5":
            makeSwitchNoise()
            ENTER_BARN_DIGIT(5)
            checkBarnCode()
        elif eventPlayer.tValue[Item.ID] == "barnPaperClue1":
            smallMessage(eventPlayer, "{0} {1} _ _ _".format(eventPlayer.barnCode[0], eventPlayer.barnCode[1]))
        elif eventPlayer.tValue[Item.ID] == "barnPaperClue2":
            smallMessage(eventPlayer, "_ _ _ {0} {1}".format(eventPlayer.barnCode[3], eventPlayer.barnCode[4]))
        elif eventPlayer.tValue[Item.ID] == "barnSafe2":
            if Equip.LITTLE_BUDDY not in eventPlayer.equipped:
                eventPlayer.equipped.append(Equip.LITTLE_BUDDY)
                manageEquips()
            eventPlayer.canLeaveBarn = true
        elif eventPlayer.tValue[Item.ID] == "outsideFridge1":
            eventPlayer.outsideMapFound = true
            eventPlayer.pauseInteraction = true
            eventPlayer.setStatusEffect(null, Status.ROOTED, INF)
            eventPlayer.disableHeroHUD()
            mapMarkerPlayers.append(eventPlayer)
            eventPlayer.startCamera(vect(-81.29, 50.24, -143.14), vect(-81.29, 50.24, -143.14) + vect(-0.00682, -0.9994, -0.03402), 0)
            wait(1)
            mapMarkerPlayers.remove(eventPlayer)
            wait(1)
            mapMarkerPlayers.append(eventPlayer)
            wait(1)
            mapMarkerPlayers.remove(eventPlayer)
            wait(1)
            mapMarkerPlayers.append(eventPlayer)
            wait(1)
            eventPlayer.enableHeroHud()
            mapMarkerPlayers.remove(eventPlayer)
            eventPlayer.stopCamera()
            eventPlayer.clearStatusEffect(Status.ROOTED)
            eventPlayer.pauseInteraction = false
        elif eventPlayer.tValue[Item.ID] == "outsideSmuggler":
            if not eventPlayer.canUtilizeSmuggler:
                CREATE_TEXT("Welcome to Tracer's Delivery Service!\nWe deliver anything to anyone anywhere!\nLifetime membership is only {0} dollars!".format(SMUGGLER_COST), OUTSIDE_SMUGGLER_TEXT_LOCATION)
            else:
                if eventPlayer.smugglerItem:
                    CREATE_TEXT("Looks like we have something for you!", OUTSIDE_SMUGGLER_TEXT_LOCATION)
                    eventPlayer.tText = eventPlayer.smugglerItem
                    smallMessage(eventPlayer, "Received {0}".format(eventPlayer.tText))
                    GIVE_ITEM(eventPlayer.smugglerItem)
                    eventPlayer.smugglerItem = null
                else:
                    CREATE_TEXT("Sorry, nothing for you", OUTSIDE_SMUGGLER_TEXT_LOCATION)

    if strContains(eventPlayer.tValue[Item.ID], "Poster"):
        if eventPlayer.tValue[Item.ID] not in eventPlayer.postersFound:
            eventPlayer.postersFound.append(eventPlayer.tValue[Item.ID])



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
        eventPlayer.tValue = GET_ITEM_ENTRY("tutGate1")
        if eventPlayer.tValue[Item.STATE] == 0:
            if SHOULD_APPLY_ITEM(eventPlayer.tValue):
                APPLY_ITEM_SUCCESS(eventPlayer.tValue)
                eventPlayer.tValue[Item.STATE]++
                SAVE_STATE(eventPlayer.tValue)
                INCREMENT_STATE("tutGate2")

                del eventPlayer.inventory[0]
                playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, null, eventPlayer, 100)
                eventPlayer.tutorialFinished = true
            else:
                APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerWires):
        eventPlayer.tValue = GET_ITEM_ENTRY("innerWires")
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
        eventPlayer.tValue = GET_ITEM_ENTRY("innerBarrel2")
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            printLog("Item state is {0}, req items {1}".format(eventPlayer.tValue[Item.STATE], len(eventPlayer.innerBarrel2[Item.REQUIRED_ITEM])))
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
        eventPlayer.tValue = GET_ITEM_ENTRY("innerGenerator")
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
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
        eventPlayer.tValue = GET_ITEM_ENTRY("innerWorkbench")
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.isDoingInnerMinigame = true
            innerMinigamePlayers.append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerRadio):
        if eventPlayer.inventory[0] == "Fiddly part":
            smallMessage(eventPlayer, "You need a reverse polarity fiddly part to work with Australian radios.\n                        Maybe you can switch this one at a workbench")
        elif eventPlayer.inventory[0] == "Reverse polarity fiddly part":
            doInnerRadioConversation()
            INCREMENT_STATE("innerRadio")
            eventPlayer.inventory.remove("Reverse polarity fiddly part")
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.innerToolbox2):
        eventPlayer.tValue = GET_ITEM_ENTRY("innerToolbox2")
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
        eventPlayer.tValue = GET_ITEM_ENTRY("outerBruce")
        if eventPlayer.tValue[Item.STATE] == 0 or eventPlayer.tValue[Item.STATE] > 8:
            CREATE_TEXT("I have enough junk in here without that cluttering the place up.", BRUCE_TEXT_LOCATION)
        elif eventPlayer.tValue[Item.STATE] < 8:
            if eventPlayer.inventory[0] == "Black battery":
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
                CREATE_TEXT("Gotta buy a membership before we can deliver anything.", INSIDE_SMUGGLER_TEXT_LOCATION)
        else:
            if eventPlayer.smugglerItem:
                CREATE_TEXT("Only one delivery at a time, love.", INSIDE_SMUGGLER_TEXT_LOCATION)
            elif len(eventPlayer.inventory) == 0:
                CREATE_TEXT("You want me to deliver the abstract notion of nothingness?", INSIDE_SMUGGLER_TEXT_LOCATION)
            else:
                CREATE_TEXT("You got it!", INSIDE_SMUGGLER_TEXT_LOCATION)
                eventPlayer.smugglerItem = eventPlayer.inventory[0]
                del eventPlayer.inventory[0]
    elif SHOULD_INTERACT(eventPlayer.outsideSmuggler):
        if not eventPlayer.canUtilizeSmuggler:
            CREATE_TEXT("Gotta buy a membership before we can deliver anything.", OUTSIDE_SMUGGLER_TEXT_LOCATION)
        else:
            if eventPlayer.smugglerItem:
                CREATE_TEXT("Only one delivery at a time, love.", OUTSIDE_SMUGGLER_TEXT_LOCATION)
            elif len(eventPlayer.inventory) == 0:
                CREATE_TEXT("You want me to deliver the abstract notion of nothingness?", OUTSIDE_SMUGGLER_TEXT_LOCATION)
            else:
                CREATE_TEXT("You got it!", OUTSIDE_SMUGGLER_TEXT_LOCATION)
                eventPlayer.smugglerItem = eventPlayer.inventory[0]
                del eventPlayer.inventory[0]
    elif SHOULD_INTERACT(eventPlayer.outerBartender):
        eventPlayer.tValue = GET_ITEM_ENTRY("outerBartender")
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
        else:
            CREATE_TEXT("Ya can't pay with that.", BARTENDER_TEXT_LOCATION)
    elif SHOULD_INTERACT(eventPlayer.outerWorkbench):
        eventPlayer.tValue = GET_ITEM_ENTRY("outerWorkbench")
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.isDoingOuterMinigame = true
            outerMinigamePlayers.append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outsideHose):
        eventPlayer.tValue = GET_ITEM_ENTRY("outsideHose")
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
    elif SHOULD_INTERACT(eventPlayer.outsideSat1):
        eventPlayer.tValue = GET_ITEM_ENTRY("outsideSat1")
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)
            eventPlayer.satsTuned++
            satUntunedPlayers[0].remove(eventPlayer)
            satTunedPlayers[0].append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outsideSat2):
        eventPlayer.tValue = GET_ITEM_ENTRY("outsideSat2")
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)
            eventPlayer.satsTuned++
            satUntunedPlayers[1].remove(eventPlayer)
            satTunedPlayers[1].append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outsideSat3):
        eventPlayer.tValue = GET_ITEM_ENTRY("outsideSat3")
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)
            eventPlayer.satsTuned++
            satUntunedPlayers[2].remove(eventPlayer)
            satTunedPlayers[2].append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer.outsideSat4):
        eventPlayer.tValue = GET_ITEM_ENTRY("outsideSat4")
        if SHOULD_APPLY_ITEM(eventPlayer.tValue):
            APPLY_ITEM_SUCCESS(eventPlayer.tValue)
            eventPlayer.tValue[Item.STATE]++
            SAVE_STATE(eventPlayer.tValue)
            eventPlayer.satsTuned++
            satUntunedPlayers[3].remove(eventPlayer)
            satTunedPlayers[3].append(eventPlayer)
        else:
            APPLY_ITEM_FAIL()
    else:
        pass
        

    
# SPECIAL EFFECTS

# Tutorial gate

#!define GATE_EFFECT Beam.TORBJORN_TURRET_SIGHT
#!define GATE_OPEN_TIME 2
#!define GATE_OFFSET 0.52
playervar gate1Visibility
playervar gate1Start = vect(-99.01, 10.93, -91.03)
playervar gate1End = vect(-101.64, 10.93, -90.46)
playervar gate2Start = vect(-94.20, 10.93, -92.04)
playervar gate2End = vect(-91.58, 10.93, -92.60)

rule "Tutorial gate visual":
    @Event eachPlayer
    @Condition not eventPlayer.isDummy()

    eventPlayer.gate1Visibility = eventPlayer

    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate1Start, eventPlayer.gate1End, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate1Start + vect(0, GATE_OFFSET, 0) * 1, eventPlayer.gate1End + vect(0, GATE_OFFSET, 0) * 1, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate1Start + vect(0, GATE_OFFSET, 0) * 2, eventPlayer.gate1End + vect(0, GATE_OFFSET, 0) * 2, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate1Start + vect(0, GATE_OFFSET, 0) * 3, eventPlayer.gate1End + vect(0, GATE_OFFSET, 0) * 3, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate1Start + vect(0, GATE_OFFSET, 0) * 4, eventPlayer.gate1End + vect(0, GATE_OFFSET, 0) * 4, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate1Start + vect(0, GATE_OFFSET, 0) * 5, eventPlayer.gate1End + vect(0, GATE_OFFSET, 0) * 5, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate2Start, eventPlayer.gate2End, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate2Start + vect(0, GATE_OFFSET, 0) * 1, eventPlayer.gate2End + vect(0, GATE_OFFSET, 0) * 1, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate2Start + vect(0, GATE_OFFSET, 0) * 2, eventPlayer.gate2End + vect(0, GATE_OFFSET, 0) * 2, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate2Start + vect(0, GATE_OFFSET, 0) * 3, eventPlayer.gate2End + vect(0, GATE_OFFSET, 0) * 3, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate2Start + vect(0, GATE_OFFSET, 0) * 4, eventPlayer.gate2End + vect(0, GATE_OFFSET, 0) * 4, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createBeam(eventPlayer.gate1Visibility, GATE_EFFECT, eventPlayer.gate2Start + vect(0, GATE_OFFSET, 0) * 5, eventPlayer.gate2End + vect(0, GATE_OFFSET, 0) * 5, Color.RED, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    createEffect(eventPlayer.gate1Visibility, Effect.ZARYA_PARTICLE_BEAM_SOUND, null, updateEveryTick(eventPlayer.getPosition()), (5 - distance(vect(-100.32, 11.44, -90.75), updateEveryTick(eventPlayer.getPosition()))) * 30, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(eventPlayer.gate1Visibility, Effect.ZARYA_PARTICLE_BEAM_SOUND, null, updateEveryTick(eventPlayer.getPosition()), (5 - distance(vect(-92.97, 11.44, -92.29), updateEveryTick(eventPlayer.getPosition()))) * 30, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

rule "Tutorial gate barrier":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition not eventPlayer.tutorialFinished
    @Condition DIST_TO_WALL(vect(-101.64, 0, -90.46), vect(-91.58, 0, -92.60), updateEveryTick(eventPlayer.getPosition())) < 0.5

    do:
        eventPlayer.clearStatusEffect(Status.INVINCIBLE)
        damage(eventPlayer, eventPlayer, 50)
        eventPlayer.setMoveSpeed(5)
        eventPlayer.applyImpulse(vect(2.14, 6, 10.06), 8, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
        wait(0.1)
        eventPlayer.setStatusEffect(null, Status.INVINCIBLE, INF)
        eventPlayer.setHealth(200)
    while RULE_CONDITION
    eventPlayer.setMoveSpeed(100)

    # MAKE_DAMAGE_WALL(vect(-101.64, 10.19, -90.47), vect(-99.01, 14.05, -91.02), "Ouch!")
    # MAKE_DAMAGE_WALL(vect(-94.21, 10.19, -92.06), vect(-91.58, 14.05, -92.61), "Ouch!")

    # wait(0.016, Wait.ABORT_WHEN_FALSE)
    # goto RULE_START

    # if DIST_TO_WALL_2(vect(-101.64, 10.19, -90.47), vect(-99.01, 14.05, -91.02), eventPlayer.getPosition()) > 0:
    #     pass

    # hudHeader(eventPlayer, "dist: {0}".format(DIST_TO_WALL_2(vect(-101.64, 10.19, -90.47), vect(-99.01, 14.05, -91.02), eventPlayer.getPosition())), HudPosition.RIGHT, 300, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)

rule "Remove tutorial gate":
    @Event eachPlayer
    @Condition eventPlayer.tutorialFinished

    chase(eventPlayer.gate1End, eventPlayer.gate1Start, duration=GATE_OPEN_TIME, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.gate2End, eventPlayer.gate2Start, duration=GATE_OPEN_TIME, ChaseReeval.DESTINATION_AND_DURATION)

    wait(GATE_OPEN_TIME)

    eventPlayer.gate1Visibility = null

# Dark and scary barrier

#!define DARK_AND_SCARY_MESSAGE "It's too dark and scary out there"

rule "Create lights out barriers":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition not eventPlayer.lightsOn

    MAKE_WALL(vect(-85.53, 10.44, -97.39), vect(-85, 14.38, -94.87), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(vect(-104.47, 5.37, -128.85), vect(-99.85, 12.44, -107.17), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(vect(-103.34, 6.04, -140.02), vect(-102.20, 16.33, -134.55), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(vect(-99.65, 12.44, -153.76), vect(-102.71, 16, -149.09), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(vect(-97.29, 12.44, -169.53), vect(-96.75, 16, -166.99), DARK_AND_SCARY_MESSAGE)

    wait(0.016, Wait.ABORT_WHEN_FALSE)
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

#!define SCRAPYARD_OUTSIDE_MESSAGE "The sun is too bright for your sensitive complexion"

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

    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Junkertown exit wall

#!define JUNKERTOWN_EXIT_WALL_MESSAGE "The guard will see you if you go any further"

rule "Junkertown entry wall":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition eventPlayer.canGoOutside

    MAKE_WALL(vect(-12.67, 6.20, -83.32), vect(-31.22, 16, -86.91), JUNKERTOWN_EXIT_WALL_MESSAGE)
    MAKE_WALL(vect(-41.66, 12.54, -82.73), vect(-44.69, 15.31, -80.84), JUNKERTOWN_EXIT_WALL_MESSAGE)

    wait(0.016, Wait.ABORT_WHEN_FALSE)
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
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Barn secret wall

rule "Create barn secret wall":
    @Event eachPlayer
    @Condition eventPlayer.isHog
    @Condition not eventPlayer.canAccessBarnSecret

    MAKE_WALL(vect(55.83, 9, -65.80), vect(52.28, 11.81, -65.50), "Enter the code first!")

    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Junkertown entry wall

#!define JUNKERTOWN_ENTRY_WALL_MESSAGE "The Queen isn't too keen on you coming back after what happened last time"

rule "Junkertown entry wall":
    @Event eachPlayer
    @Condition eventPlayer.isHog
    @Condition eventPlayer.canLeaveBarn

    MAKE_WALL(vect(-50.22, 4.35, -41.54), vect(-48.34, 8.47, -47.74), JUNKERTOWN_ENTRY_WALL_MESSAGE)
    MAKE_WALL(vect(-48.99, 9.49, -46.47), vect(-47.91, 13.48, -50.19), JUNKERTOWN_ENTRY_WALL_MESSAGE)
    MAKE_WALL(vect(-28.33, 4.48, -64.23), vect(-25.17, 8.48, -66.02), JUNKERTOWN_ENTRY_WALL_MESSAGE)

    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Mole person hiding text

rule "Mole person shuffle text":
    @Event eachPlayer
    @Condition not eventPlayer.isMolePersonFriend
    @Condition distance(eventPlayer, MOLE_PERSON_TEXT_LOCATION) < 16

    CREATE_TEXT("*shuffle shuffle*", MOLE_PERSON_TEXT_LOCATION)

rule "Mole person away text":
    @Event eachPlayer
    @Condition not eventPlayer.isMolePersonFriend
    @Condition distance(eventPlayer, MOLE_PERSON_TEXT_LOCATION) < 10

    CREATE_TEXT("*mole away!*", MOLE_PERSON_TEXT_LOCATION)
    wait(0.5)
    popTextDeleteQueue()



# DEBUG FUNCTIONS
globalvar debugPlayers = []

playervar pointHelperEffect
playervar pointHelperHud
playervar pointHelperState = 0


rule "test":
    @Event global

    createBeam(getAllPlayers(), Beam.GRAPPLE, vect(5.77, 16.46, -44.27), vect(-1.10, 15.52, -59.41), null, EffectReeval.VISIBILITY)
    createBeam(getAllPlayers(), Beam.GRAPPLE, vect(-1.10, 15.52, -59.41), vect(12.34, 17.12, -88.35), null, EffectReeval.VISIBILITY)
    createBeam(getAllPlayers(), Beam.GRAPPLE, vect(12.34, 17.12, -88.35), vect(20.92, 15.01, -86.41), null, EffectReeval.VISIBILITY)
    createBeam(getAllPlayers(), Beam.GRAPPLE, vect(20.92, 15.01, -86.41), vect(26.18, 15.70, -90.36), null, EffectReeval.VISIBILITY)
    createBeam(getAllPlayers(), Beam.GRAPPLE, vect(26.18, 15.70, -90.36), vect(29.31, 16.27, -90.89), null, EffectReeval.VISIBILITY)


rule "trigger all npcs":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) and eventPlayer.isHoldingButton(Button.RELOAD)

    INCREMENT_STATE("outerBruce")

rule "Debug on":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.isHoldingButton(Button.ULTIMATE)

    if eventPlayer in debugPlayers:
        debugPlayers.remove(eventPlayer)
    else:
        debugPlayers.append(eventPlayer)

playervar isMercyUlting = false

rule "Be mercy":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.JUMP) and eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.isMercyUlting = false
    eventPlayer.startForcingHero(Hero.MERCY)

rule "Toggle infinite mercy ult":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    @Condition eventPlayer.getCurrentHero() == Hero.MERCY

    eventPlayer.isMercyUlting = not eventPlayer.isMercyUlting

globalvar x

rule "setup":
    @Event global

    chase(x, INF, rate=2 * PI / 32, ChaseReeval.NONE)

rule "trip cam":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    eventPlayer.disableHeroHUD()
    eventPlayer.startCamera(vect(-81.25, 14.6, -143.31), vect(-81.25 - sin(x - 0.18), 14.6, -143.31 + cos(x - 0.18)), 0)
    # GIVE_ITEM("Strong alcohol")
    GIVE_ITEM("Tuned satellite tuner")
    satUntunedPlayers[0].append(eventPlayer)
    satUntunedPlayers[1].append(eventPlayer)
    satUntunedPlayers[2].append(eventPlayer)
    satUntunedPlayers[3].append(eventPlayer)

rule "stop trip cam":
    @Event eachPlayer
    @Condition not eventPlayer.isHoldingButton(Button.RELOAD)

    eventPlayer.enableHeroHud()
    eventPlayer.stopCamera()

rule "Mercy infinite ult":
    @Event eachPlayer
    @Condition eventPlayer.getCurrentHero() == Hero.MERCY
    @Condition eventPlayer.isMercyUlting
    @Condition not eventPlayer.isUsingUltimate()

    eventPlayer.setUltCharge(100)
    eventPlayer.forceButtonPress(Button.ULTIMATE)

rule "Easy restart":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)

    restartMatch()

rule "Point helper":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.canBeTheOtherGuy = true

    if eventPlayer.pointHelperState == 0:
        hudHeader(eventPlayer, "Position: {0}".format(updateEveryTick(raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 3, getAllPlayers(), eventPlayer, true).getHitPosition() * 1000)), HudPosition.LEFT, 99, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
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
    @Condition eventPlayer == hostPlayer

    for eventPlayer.tText in range(len(eventPlayer.itemPoints)):
        if strContains(eventPlayer.itemPoints[eventPlayer.tText][Item.ID], "outerDoor"):
            createEffect(debugPlayers, Effect.SPHERE, Color.PURPLE, eventPlayer.itemPoints[eventPlayer.tText][Item.POINT], eventPlayer.itemPoints[eventPlayer.tText][Item.RADIUS], EffectReeval.VISIBILITY)

rule "Noclip on":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true
    
    eventPlayer.disableEnvironmentCollision(false)

rule "Noclip off":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == false
    
    eventPlayer.enableEnvironmentCollision()

rule "Display stats":
    @Event eachPlayer

    hudHeader(eventPlayer, "pos: {0}".format(eventPlayer.getEyePosition()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(eventPlayer, "facing: {0}".format(eventPlayer.getFacingDirection() * 1000), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(eventPlayer, "is outside: {0}".format(eventPlayer.inSunlight), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    # hudHeader(eventPlayer, "mv1: {0} / {1}".format(eventPlayer.innerMinigameValue1 % (2 * PI), 3*PI/2), HudPosition.LEFT, 6, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    # hudHeader(eventPlayer, "mv2: {0} / {1}".format(eventPlayer.innerMinigameValue2 % (2 * PI / 3), PI/6), HudPosition.LEFT, 7, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    # hudHeader(eventPlayer, "doing minigame: {0}".format(eventPlayer.isDoingOuterMinigame), HudPosition.LEFT, 8, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    # hudHeader(eventPlayer, "done minigame: {0}".format(eventPlayer.hasFinishedOuterMinigame), HudPosition.LEFT, 9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    # hudHeader(eventPlayer, "workbench state: {0}".format(eventPlayer.outerWorkbench[Item.STATE]), HudPosition.LEFT, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


    hudHeader(eventPlayer, "load {0}".format(getServerLoad()), HudPosition.RIGHT, 11, Color.RED, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "peak {0}".format(getPeakServerLoad()), HudPosition.RIGHT, 12, Color.RED, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "avg {0}".format(getAverageServerLoad()), HudPosition.RIGHT, 13, Color.RED, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "effects {0}".format(getNumberOfEntityIds()), HudPosition.RIGHT, 14, Color.VIOLET, HudReeval.STRING, SpecVisibility.NEVER)
