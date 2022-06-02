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



# GLOBAL VARIABLES

globalvar playersInDark = []
globalvar innerWirePlayers = []
globalvar powerPanelPlayers = [[], [], [], [], []]
globalvar radioSmokePlayers = []
globalvar barnHintPlayers = []



# PLAYER VARIABLES

playervar effectDeleteQueue = []

playervar argStack = []

# General temp variables
playervar tIndex
playervar tValue
playervar tStart
playervar tEnd
playervar tPos
playervar tText

# Player state
playervar junkPos
playervar junkFacing
playervar hogPos
playervar hogFacing
playervar isJunk
playervar isHog
playervar junkInventory
playervar hogInventory
playervar inventory
playervar inSunlight

# Game state
playervar tutorialFinished
playervar wiresConnected
playervar generatorOn
playervar powerSwitched
playervar lightsOn

playervar canBeTheOtherGuy

playervar canGoOutside

playervar barnCode
playervar barnCodeInputted
playervar canLeaveBarn
playervar canAccessBarnSecret

# Item points

playervar itemPoints
playervar itemIds

# tutorial room
playervar tutSafe1
playervar tutSafe2
playervar tutSafe3
playervar tutSafe4
playervar tutSafe5
playervar tutGold

# lights on section
playervar innerFridge
playervar innerChest1
playervar innerLocker1
playervar innerLocker2
playervar innerLocker3
playervar innerLocker4
playervar innerLocker5
playervar innerBarrel1
playervar innerBarrel3
playervar innerSwitch1
playervar innerSwitch2
playervar innerSwitch3
playervar innerSwitch4
playervar innerSwitch5
playervar innerPowerBox

# larger inner section
playervar innerThrone
playervar innerRadio
playervar innerChest2
playervar innerToolbox1
playervar innerToolbox2
playervar innerSmallToolbox1
playervar innerTireRack
playervar innerBrokenMech1
playervar innerBrokenMech2
playervar innerMech1
playervar innerMech2

# courtyard area

# barn area
playervar barnRadio
playervar barnPachimari
playervar barnBike
playervar barnFuelMachine
playervar barnFridge
playervar barnTireRack
playervar barnPlan

playervar barnToolbox1
playervar barnToolbox2
playervar barnSmallToolbox1
playervar barnSafe1
playervar barnSafe2
playervar barnSafe3
playervar barnEmptyShelf

playervar barnPaperClue1
playervar barnPaperClue2

playervar barnSwitch1
playervar barnSwitch2
playervar barnSwitch3
playervar barnSwitch4
playervar barnSwitch5
playervar barnCodePanel

# larger outside area
playervar outsideJunkWorkbench
playervar outsideCart
playervar outsideSafe
playervar outsideFridge1
playervar outsideFridge2
playervar outsideFridge3
playervar outsideFridge4
playervar outsideIceBox
playervar outsideToolbox1
playervar outsideToolbox2
playervar outsideSmallToolbox
playervar outsideChest1
playervar outsideChest2
playervar outsideChest3
playervar outsideChest4
playervar outsideChest5

# Interaction points

playervar tutGate1
playervar tutGate2

playervar innerWires
playervar innerBarrel2
playervar innerGenerator



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
#!define GET_ITEM_ENTRY(eventPlayer, id) [elem for elem in eventPlayer.itemPoints if elem[Item.ID] == id][0]

# save an item entry
#!define SAVE_STATE(eventPlayer, item) eventPlayer.tIndex = eventPlayer.itemIds.index(item[Item.ID]) \
eventPlayer.itemPoints[eventPlayer.tIndex] = item

# distance between two vectors ignoring the height component
#!define DIST_2D(v1, v2) distance(vect((v1).x, 0, (v1).z), vect((v2).x, 0, (v2).z))

# distance from pos to the vertical plane defined by start and end vectors
#!define DIST_TO_WALL(start, end, pos) (sinDeg(angleBetweenVectors(vect(end.x - start.x, 0, end.z - start.z), vect(pos.x - start.x, 0, pos.z - start.z))) * DIST_2D(start, pos))

# MAKE_WALL creates a vertical wall from start to end, pushing 90 degrees clockwise to the (end - start) vector
# when hit, displays the message, but with a timeout of WALL_MESSAGE_TIMEOUT
# it's an instantaneous check, so must be rerun every tick
playervar isShowingWallMessage = false

def doWallMessageTimeout():
    eventPlayer.isShowingWallMessage = true
    wait(WALL_MESSAGE_TIMEOUT)
    eventPlayer.isShowingWallMessage = false

#!define MAKE_WALL(eventPlayer, start, end, message) if DIST_2D(((start) + (end)) / 2, eventPlayer.getPosition()) < distance(start, end) / 2 and eventPlayer.getPosition().y >= start.y and eventPlayer.getPosition().y <= end.y and DIST_TO_WALL(start, end, eventPlayer.getPosition()) < 1: \
    eventPlayer.setMoveSpeed(5) \
    eventPlayer.applyImpulse(normalize(vect(-((end) - (start)).z, 0, ((end) - (start)).x)), 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION) \
    if eventPlayer.isShowingWallMessage == false: \
        smallMessage(eventPlayer, message) \
        async(doWallMessageTimeout(), AsyncBehavior.RESTART) \
    eventPlayer.setMoveSpeed(100)

# Push and pop effects using the effect deletion queue
def pushEffectDeleteQueue():
    eventPlayer.effectDeleteQueue.append(getLastCreatedEntity())

def popEffectDeleteQueue():
    destroyEffect(eventPlayer.effectDeleteQueue[0])
    del eventPlayer.effectDeleteQueue[0]

# Increments the state of the item with the given id
#!define INCREMENT_STATE(eventPlayer, id) eventPlayer.tValue = GET_ITEM_ENTRY(eventPlayer, id) \
eventPlayer.tIndex = eventPlayer.itemIds.index(eventPlayer.tValue[Item.ID]) \
eventPlayer.tValue[Item.STATE]++ \
eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue

# Toggles visiblity of the given power panel switch
#!define TOGGLE_POWER_SWITCH(eventPlayer, index) if eventPlayer in powerPanelPlayers[index]: \
    powerPanelPlayers[index].remove(eventPlayer) \
else: \
    powerPanelPlayers[index].append(eventPlayer)

# Checks if the player has activated all the power switches
def checkPowerPanel():
    if all([eventPlayer not in elem for elem in powerPanelPlayers]):
        eventPlayer.powerSwitched = true

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
        createDummy(Hero.ZENYATTA, Team.2, 1, vect(54.41, 9.5, -64.48), vect(1, 0, 0))
        getPlayersInSlot(1, Team.2).setInvisibility(Invis.ALL)
        wait(0.5)
        destroyDummy(Team.2, 1)

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

    createDummy(Hero.MERCY, Team.2, -1, vect(28.66, 10.54, -81.27), vect(-1, 0, 0))
    getPlayersOnHero(Hero.MERCY, Team.2).disablePlayerCollision()
    getPlayersOnHero(Hero.MERCY, Team.2).setStatusEffect(null, Status.INVINCIBLE, 9999)
    getPlayersOnHero(Hero.MERCY, Team.2).setInvisibility(Invis.ENEMIES)

rule "Keep match time at 0 to prevent time based voice lines":
    @Event global
    @Condition getMatchTime() > 0

    setMatchTime(0)

rule "Global setup":
    @Event global

    disableMusic()
    disableAnnouncer()
    disableGamemodeCompletion()
    setObjectiveDescription(getAllPlayers(), "Escape", HudReeval.VISIBILITY_AND_STRING)
    startForcingSpawn(Team.ALL, 2)
    getAllPlayers().disableNameplatesFor(getAllPlayers())

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
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.83, 13.5, -153.41), 3, EffectReeval.VISIBILITY)
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.54, 13.5, -152.50), 3, EffectReeval.VISIBILITY)
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-101.18, 13.5, -151.41), 3, EffectReeval.VISIBILITY)
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.95, 13.5, -150.25), 3, EffectReeval.VISIBILITY)
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.52, 13.5, -149.31), 3, EffectReeval.VISIBILITY)
    
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-99.83, 13.5, -153.41), 3, EffectReeval.VISIBILITY)
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-100.54, 13.5, -152.50), 3, EffectReeval.VISIBILITY)
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-101.18, 13.5, -151.41), 3, EffectReeval.VISIBILITY)
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.95, 13.5, -150.25), 3, EffectReeval.VISIBILITY)
    # createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-102.52, 13.5, -149.31), 3, EffectReeval.VISIBILITY)

    # window 7
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-93.95, 11.44, -169.05), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-93.95, 11.94, -169.05), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-93.95, 12.44, -169.05), 3, EffectReeval.VISIBILITY)
    createEffect(playersInDark, Effect.BAD_AURA, Color.BLACK, vect(-93.95, 12.94, -169.05), 3, EffectReeval.VISIBILITY)

    # radio smoke effect
    createEffect(radioSmokePlayers, Effect.CLOUD, Color.BLACK, vect(-90.05, 8.69, -103.28), 0.1, EffectReeval.VISIBILITY)

    # barn paper clues
    createEffect(barnHintPlayers, Effect.SPARKLES, Color.YELLOW, vect(58.30, 8.2, -93.83), 0.3, EffectReeval.VISIBILITY)
    createEffect(barnHintPlayers, Effect.SPARKLES, Color.YELLOW, vect(42.25, 15.2, -71.88), 0.3, EffectReeval.VISIBILITY)

def playerInitialState():
    # Player state
    eventPlayer.junkPos = vect(-95.58, 12.17, -86.79)
    eventPlayer.junkFacing = vect(1, 0, 0)

    # top area start
    eventPlayer.hogPos = vect(68.39, 13.91, -86.84)
    eventPlayer.hogFacing = vect(0.86, -0.51, 0)

    eventPlayer.isJunk = false
    eventPlayer.isHog = false

    eventPlayer.junkInventory = []
    eventPlayer.hogInventory = []
    eventPlayer.inventory = []

    eventPlayer.inSunlight = false

    # Game state
    eventPlayer.tutorialFinished = false
    eventPlayer.wiresConnected = false
    eventPlayer.generatorOn = false
    eventPlayer.powerSwitched = false
    eventPlayer.lightsOn = false

    eventPlayer.canBeTheOtherGuy = false

    eventPlayer.canGoOutside = false

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

    # tutorial room
    eventPlayer.tutSafe1 = ["tutSafe1", 0, vect(-104.92, 12.06, -84.28), 1.2, ["All that's inside are a few dusty cobwebs"], null, true]
    eventPlayer.tutSafe2 = ["tutSafe2", 0, vect(-100.95, 11.28, -80.59), 0.7, ["This safe is rusted shut, despite having gold hinges"], null, true]
    eventPlayer.tutSafe3 = ["tutSafe3", 0, vect(-103.16, 11.95, -76.61), 1, ["The box is buried under a mound of gold and can't be opened"], null, true]
    eventPlayer.tutSafe4 = ["tutSafe4", 0, vect(-89.28, 12.44, -72.22), 1.2, ["The door of the safe is too heavy to lift"], null, true]
    eventPlayer.tutSafe5 = ["tutSafe5", 0, vect(-88.78, 11.51, -90.72), 0.7, ["The door squeaks open and you find a rusty key inside"], "Rusty key", true]
    eventPlayer.tutGold = ["tutGold", 0, vect(-95.60, 11.38, -86.96), 1.5, ["A giant safe filled with gold, perfect for sleeping in"]]

    # lights on section
    eventPlayer.innerFridge = ["innerFridge", 0, vect(-110.04, 6.97, -111.51), 1.1, ["The fridge is full of fish heads and half eaten Chinese food"], null, true]
    eventPlayer.innerChest1 = ["innerChest1", 0, vect(-114.91, 7.07, -124.08), 1.2, ["Who kept an empty petrol can in here?"], "Empty petrol can", true]
    eventPlayer.innerLocker1 = ["innerLocker1", 0, vect(-112.76, 7.55, -134.80), 1.2, ["locker 1"], null, true]
    eventPlayer.innerLocker2 = ["innerLocker2", 0, vect(-113.80, 7.55, -139.10), 1.2, ["locker 2"], null, true]
    eventPlayer.innerLocker3 = ["innerLocker3", 0, vect(-112.58, 7.55, -141.24), 1.2, ["locker 3"], null, true]
    eventPlayer.innerLocker4 = ["innerLocker4", 0, vect(-108.08, 7.55, -142.79), 1.2, ["There's an old extension cord hidden in the back"], "Extension cord", true]
    eventPlayer.innerLocker5 = ["innerLocker5", 0, vect(-106.71, 7.55, -141.16), 1.2, ["You don't even want to think about whose swimsuit that is"], null, true]

    eventPlayer.innerBarrel1 = ["innerBarrel1", 0, vect(-113.43, 7.02, -116.14), 0.5, ["Barrel 1"], null, true]
    eventPlayer.innerBarrel3 = ["innerBarrel3", 0, vect(-105.32, 12.79, -132.71), 0.5, ["Barrel 3"], null, true]

    eventPlayer.innerSwitch1 = ["innerSwitch1", 0, vect(-111.46, 14.145, -137.47), 0.05, null]
    eventPlayer.innerSwitch2 = ["innerSwitch2", 0, vect(-111.46, 14.071, -137.47), 0.05, null]
    eventPlayer.innerSwitch3 = ["innerSwitch3", 0, vect(-111.46, 13.994, -137.47), 0.05, null]
    eventPlayer.innerSwitch4 = ["innerSwitch4", 0, vect(-111.46, 13.914, -137.47), 0.05, null]
    eventPlayer.innerSwitch5 = ["innerSwitch5", 0, vect(-111.46, 13.835, -137.47), 0.05, null]
    eventPlayer.innerPowerBox = ["innerPowerBox", 0, vect(-111.73, 14.04, -137.34), 0.5, null]

    # larger inner section
    eventPlayer.innerThrone = ["innerThrone", 0, vect(-88.94, 8.40, -102.99), 0.75, ["The queen's throne... oh how you want to sit on it"]]
    eventPlayer.innerRadio = ["innerRadio", 0, vect(-90.05, 8.69, -103.28), 0.3, ["The radio the queen uses. It seems to be broken though"]]

    eventPlayer.innerChest2 = ["innerChest2", 0, vect(-101.16, 8.12, -198.06), 1.2, ["A chest 2"], null, true]
    eventPlayer.innerToolbox1 = ["innerToolbox1", 0, vect(-103.25, 8.92, -182.63), 0.75, ["A toolbox 1"], null, true]
    eventPlayer.innerToolbox2 = ["innerToolbox2", 0, vect(-103.00, 8.01, -182.63), 0.75, ["A toolbox 2"], null, true]
    eventPlayer.innerSmallToolbox1 = ["innerSmallToolbox1", 0, vect(-102.65, 9.06, -181.25), 0.5, ["A small toolbox 1"], null, true]
    eventPlayer.innerTireRack = ["innerTireRack", 0, vect(-87.96, 8.63, -201.60), 1.8, ["Why are there rubber tires when all the cars hover?"]]

    eventPlayer.innerBrokenMech1 = ["innerBrokenMech1", 0, vect(-88.35, 8.26, -142.03), 2, ["This mech seems to be missing a limb. You sympathize with it"]]
    eventPlayer.innerBrokenMech2 = ["innerBrokenMech2", 0, vect(-75.42, 8.52, -146.11), 2, ["A broken mech 2"]]
    eventPlayer.innerMech1 = ["innerMech1", 0, vect(-90.47, 10.09, -177.75), 2, ["A fully working mech 1"]]
    eventPlayer.innerMech2 = ["innerMech2", 0, vect(-94.87, 10.11, -178.01), 2, ["A fully working mech 2"]]

    # courtyard area


    # barn area
    eventPlayer.barnRadio = ["barnRadio", 0, vect(69.46, 15.15, -86.83), 0.7, ["That idiot managed to blow up the only working radio"]]
    eventPlayer.barnPachimari = ["barnPachimari", 0, vect(69.81, 10.58, -80.19), 1.2, ["Despite your love for them, you were never any good at these things"]]
    eventPlayer.barnBike = ["barnBike", 0, vect(54.56, 10.65, -78.11), 2.5, ["bike"]]
    eventPlayer.barnFuelMachine = ["barnFuelMachine", 0, vect(69.01, 10.34, -84.15), 1.2, ["fuel machine"], null, true]
    eventPlayer.barnFridge = ["barnFridge", 0, vect(66.91, 10.37, -67.64), 1, ["fridge"], null, true]
    eventPlayer.barnTireRack = ["barnTireRack", 0, vect(44.07, 10.12, -88.71), 1.5, ["This rack of hover pads is entirely unremarkable"], null, null, true]
    eventPlayer.barnPlan = ["barnPlan", 0, vect(44.03, 11.11, -71.35), 1.5, ["Things didn't to according to plan"], null, null, true]

    eventPlayer.barnToolbox1 = ["barnToolbox1", 0, vect(49.62, 10.55, -75.25), 0.75, ["toolbox 1"], null, true]
    eventPlayer.barnToolbox2 = ["barnToolbox2", 0, vect(50.55, 9.42, -75.90), 0.75, ["toolbox 2"], null, true]
    eventPlayer.barnSmallToolbox1 = ["barnSmallToolbox1", 0, vect(49.20, 10.27, -79.17), 0.5, ["small toolbox 1"], null, true]
    eventPlayer.barnSafe1 = ["barnSafe1", 0, vect(60.60, 10.01, -65.34), 1, ["safe 1"], null, true, true]
    eventPlayer.barnSafe2 = ["barnSafe2", 0, vect(60.52, 9.50, -63.60), 0.8, ["You pick up your little buddy and place him carefully in your bag"], "Little buddy", true]
    eventPlayer.barnSafe3 = ["barnSafe3", 0, vect(56.13, 9.74, -62.70), 0.7, ["safe 3"], null, true, true]
    eventPlayer.barnEmptyShelf = ["barnEmptyShelf", 0, vect(50.05, 10.56, -63.46), 2, ["Times have been rough lately"], null, true, true]

    eventPlayer.barnPaperClue1 = ["barnPaperClue1", 0, vect(58.30, 9, -93.83), 0.3, null]
    eventPlayer.barnPaperClue2 = ["barnPaperClue2", 0, vect(42.25, 16, -71.88), 0.3, null]

    eventPlayer.barnSwitch1 = ["barnSwitch1", 0, vect(56.48, 10.655, -66.584), 0.05, null]
    eventPlayer.barnSwitch2 = ["barnSwitch2", 0, vect(56.48, 10.581, -66.584), 0.05, null]
    eventPlayer.barnSwitch3 = ["barnSwitch3", 0, vect(56.48, 10.504, -66.584), 0.05, null]
    eventPlayer.barnSwitch4 = ["barnSwitch4", 0, vect(56.48, 10.424, -66.584), 0.05, null]
    eventPlayer.barnSwitch5 = ["barnSwitch5", 0, vect(56.48, 10.345, -66.584), 0.05, null]

    # larger outside area
    eventPlayer.outsideJunkWorkbench = ["outsideJunkWorkbench", 0, vect(31.57, 10.71, -95.93), 1.2, ["outsideJunkWorkbench"]]
    eventPlayer.outsideCart = ["outsideCart", 0, vect(30.07, 10.16, -81.47), 3, ["outsideCart"]]
    eventPlayer.outsideSafe = ["outsideSafe", 0, vect(21.24, 10.90, -88.37), 0.7, ["outsideSafe"], null, true]
    eventPlayer.outsideIceBox = ["outsideIceBox", 0, vect(-32.99, 5.36, -29.36), 1, ["outsideIceBox"], null, true, true]
    eventPlayer.outsideFridge1 = ["outsideFridge1", 0, vect(20.48, 11.05, -95.08), 1, ["outsideFridge1"], null, true]
    eventPlayer.outsideFridge2 = ["outsideFridge2", 0, vect(-5.68, 13.51, -74.65), 1.2, ["outsideFridge2"], null, true]
    eventPlayer.outsideFridge3 = ["outsideFridge3", 0, vect(-31.79, 5.62, -28.84), 0.8, ["outsideFridge3"], null, true, true]
    eventPlayer.outsideFridge4 = ["outsideFridge4", 0, vect(-31.72, 5.57, -30.10), 0.8, ["outsideFridge4"], null, true, true]
    eventPlayer.outsideToolbox1 = ["outsideToolbox1", 0, vect(-6.67, 8.55, -77.17), 0.7, ["outsideToolbox1"], null, true]
    eventPlayer.outsideToolbox2 = ["outsideToolbox2", 0, vect(-6.55, 7.60, -77.18), 0.7, ["outsideToolbox2"], null, true]
    eventPlayer.outsideSmallToolbox = ["outsideSmallToolbox", 0, vect(24.28, 9.26, -64.30), 0.5, ["outsideSmallToolbox"], null, true]
    eventPlayer.outsideChest1 = ["outsideChest1", 0, vect(19.26, 8.73, -55.36), 1.2, ["outsideChest1"], null, true]
    eventPlayer.outsideChest2 = ["outsideChest2", 0, vect(-7.98, 8.35, -47.93), 1.2, ["outsideChest2"], null, true]
    eventPlayer.outsideChest3 = ["outsideChest3", 0, vect(-7.98, 6.58, -47.93), 1.2, ["outsideChest3"], null, true]
    eventPlayer.outsideChest4 = ["outsideChest4", 0, vect(-35.12, 5.22, -43.65), 1.2, ["outsideChest4"], null, true]
    eventPlayer.outsideChest5 = ["outsideChest5", 0, vect(-50.83, 4.92, -16.62), 1.2, ["outsideChest5"], null, true]



    # Interaction points
    eventPlayer.tutGate1 = ["tutGate1", 0, vect(-100.32, 11.44, -90.75), 1.5, ["The lasers would slice you up if you tried to go through"], null, null, null, 1, ["Rusty key"], ["How does a key open a laser gate? You aren't one to think about it too hard"]]
    eventPlayer.tutGate2 = ["tutGate2", 0, vect(-92.97, 11.44, -92.29), 1.5, ["The lasers would slice you up if you tried to go through"], null, null, null, 1, ["Rusty key"], null]

    eventPlayer.innerWires = ["innerWires", 0, vect(-106.91, 12.44, -135.82), 0.4, ["The wires are sparking", "The wires are connected"], null, null, null, null, ["Extension cord"], ["You connect the wires"]]
    eventPlayer.innerBarrel2 = ["innerBarrel2", 0, vect(-103.58, 7.02, -120.15), 0.5, ["There's a little bit of petrol pooled in the bottom", "The barrel is now completely empty"], null, null, null, null, ["Empty petrol can"], ["You fill up the petrol can with with the last of the petrol"]]
    eventPlayer.innerGenerator = ["innerGenerator", 0, vect(-109.58, 13.83, -132.75), 2.5, ["The generator is cold and lifeless", "The generator hums with a dim energy"], null, null, null, null, ["Filled petrol can"], ["You pour the petrol into the generator"]]



    eventPlayer.itemPoints = [
        # tutorial room
        eventPlayer.tutSafe1,
        eventPlayer.tutSafe2,
        eventPlayer.tutSafe3,
        eventPlayer.tutSafe4,
        eventPlayer.tutSafe5,
        eventPlayer.tutGold,
        eventPlayer.tutGate1, # interact
        eventPlayer.tutGate2, # interact

        # lights on section
        eventPlayer.innerFridge,
        eventPlayer.innerChest1,
        eventPlayer.innerLocker1,
        eventPlayer.innerLocker2,
        eventPlayer.innerLocker3,
        eventPlayer.innerLocker4,
        eventPlayer.innerLocker5,

        eventPlayer.innerBarrel1,
        eventPlayer.innerBarrel3,

        eventPlayer.innerSwitch1,
        eventPlayer.innerSwitch2,
        eventPlayer.innerSwitch3,
        eventPlayer.innerSwitch4,
        eventPlayer.innerSwitch5,
        eventPlayer.innerPowerBox,

        eventPlayer.innerWires, # interact
        eventPlayer.innerBarrel2, # interact
        eventPlayer.innerGenerator, # interact

        # larger inner section
        eventPlayer.innerThrone,
        eventPlayer.innerRadio,

        eventPlayer.innerChest2,
        eventPlayer.innerToolbox1,
        eventPlayer.innerToolbox2,
        eventPlayer.innerSmallToolbox1,
        eventPlayer.innerTireRack,

        eventPlayer.innerBrokenMech1,
        eventPlayer.innerBrokenMech2,
        eventPlayer.innerMech1,
        eventPlayer.innerMech2,

        # courtyard area


        # barn area
        eventPlayer.barnRadio,
        eventPlayer.barnPachimari,
        eventPlayer.barnBike,
        eventPlayer.barnFuelMachine,
        eventPlayer.barnFridge,
        eventPlayer.barnTireRack,
        eventPlayer.barnPlan,

        eventPlayer.barnToolbox1,
        eventPlayer.barnToolbox2,
        eventPlayer.barnSmallToolbox1,
        eventPlayer.barnSafe1,
        eventPlayer.barnSafe2,
        eventPlayer.barnSafe3,
        eventPlayer.barnEmptyShelf,

        eventPlayer.barnPaperClue1,
        eventPlayer.barnPaperClue2,

        eventPlayer.barnSwitch1,
        eventPlayer.barnSwitch2,
        eventPlayer.barnSwitch3,
        eventPlayer.barnSwitch4,
        eventPlayer.barnSwitch5,

        # larger outside area
        eventPlayer.outsideJunkWorkbench,
        eventPlayer.outsideCart,
        eventPlayer.outsideSafe,
        eventPlayer.outsideFridge1,
        eventPlayer.outsideFridge2,
        eventPlayer.outsideFridge3,
        eventPlayer.outsideFridge4,
        eventPlayer.outsideIceBox,
        eventPlayer.outsideToolbox1,
        eventPlayer.outsideToolbox2,
        eventPlayer.outsideSmallToolbox,
        eventPlayer.outsideChest1,
        eventPlayer.outsideChest2,
        eventPlayer.outsideChest3,
        eventPlayer.outsideChest4,
        eventPlayer.outsideChest5,
    ]

    eventPlayer.itemIds = [elem[Item.ID] for elem in eventPlayer.itemPoints]



    # Other state setup
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

    radioSmokePlayers.remove(eventPlayer)
    # TODO REMOVE
    radioSmokePlayers.append(eventPlayer)

    barnHintPlayers.remove(eventPlayer)
    barnHintPlayers.append(eventPlayer)

    eventPlayer.startForcingHero(Hero.JUNKRAT)
    eventPlayer.teleport(eventPlayer.junkPos)
    eventPlayer.setFacing(eventPlayer.junkFacing, Relativity.TO_WORLD)
    wait(RACE_CONDITION_DELAY)
    eventPlayer.isJunk = true

rule "On player join":
    @Event playerJoined
    @Team 1

    playerInitialState()

    eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 9999)
    eventPlayer.disableGamemodeHud()
    # eventPlayer.disableHeroHUD()
    eventPlayer.disableScoreboard()
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
#!define NEXT_TO(eventPlayer, pos) (distance(eventPlayer.getEyePosition(), pos) < SPAWN_CLIP_RADIUS)

rule "Walk through spawn protections enable":
    @Event eachPlayer
    @Condition NEXT_TO(eventPlayer, vect(-55.57, 9, -82.41)) or NEXT_TO(eventPlayer, vect(-66.38, 11, -80.21))

    eventPlayer.disableEnvironmentCollision(false)

rule "Walk through spawn protections disable":
    @Event eachPlayer
    @Condition not NEXT_TO(eventPlayer, vect(-55.57, 9, -82.41)) and not NEXT_TO(eventPlayer, vect(-66.38, 11, -80.21))

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



# STATE CHANGES

rule "Lights on check":
    @Event eachPlayer
    @Condition eventPlayer.wiresConnected and eventPlayer.generatorOn and eventPlayer.powerSwitched

    eventPlayer.lightsOn = true
    playersInDark.remove(eventPlayer)
    playEffect(eventPlayer, DynamicEffect.SOMBRA_TRANSLOCATING_SOUND, null, eventPlayer.getPosition() - eventPlayer.getFacingDirection() * 0.1, 100)
    INCREMENT_STATE(eventPlayer, "innerSwitch1")
    INCREMENT_STATE(eventPlayer, "innerSwitch2")
    INCREMENT_STATE(eventPlayer, "innerSwitch3")
    INCREMENT_STATE(eventPlayer, "innerSwitch4")
    INCREMENT_STATE(eventPlayer, "innerSwitch5")

# CONTROLS

rule "Switch between heroes":
    @Event eachPlayer
    @Condition eventPlayer.canBeTheOtherGuy
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    if eventPlayer.isJunk:
        eventPlayer.isJunk = false
        wait(RACE_CONDITION_DELAY)
        eventPlayer.junkInventory = eventPlayer.inventory
        eventPlayer.inventory = eventPlayer.hogInventory
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
        eventPlayer.startForcingHero(Hero.JUNKRAT)
        eventPlayer.teleport(eventPlayer.junkPos)
        eventPlayer.setFacing(eventPlayer.junkFacing, Relativity.TO_WORLD)
        eventPlayer.isJunk = true
        eventPlayer.preloadHero(Hero.JUNKRAT)

    smallMessage(eventPlayer, "You are now the other guy")


rule "Scroll inventory forwards":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)

    if len(eventPlayer.inventory) > 1:
        eventPlayer.inventory.append(eventPlayer.inventory[0])
        del eventPlayer.inventory[0]

rule "Scroll inventory backwards":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)

    if len(eventPlayer.inventory) > 1:
        eventPlayer.inventory = eventPlayer.inventory.last().concat(eventPlayer.inventory.slice(0, len(eventPlayer.inventory) - 1))

# Interact
def playGetItem():
    playEffect(eventPlayer, DynamicEffect.SOLDIER_SPRINT_START_SOUND, null, eventPlayer, 100)

def playNoItem():
    playEffect(eventPlayer, DynamicEffect.DVA_MICRO_MISSILES_EXPLOSION_SOUND, null, eventPlayer.getPosition() + eventPlayer.getFacingDirection(), 40)

#!define NOTHING_LEFT_MESSAGE "There's nothing left in there"

#!define SHOULD_INTERACT(eventPlayer, item) (distance(eventPlayer, item[Item.POINT]) < INTERACT_DISTANCE and \
distance(item[Item.POINT], eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * distance(eventPlayer.getEyePosition(), item[Item.POINT])) < (item[Item.RADIUS]) and \
(not item[Item.NEEDS_LOS] or isInLoS(item[Item.POINT], eventPlayer.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS)))

rule "Interact":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.tValue = [elem for elem in eventPlayer.itemPoints if SHOULD_INTERACT(eventPlayer, elem)]

    if len(eventPlayer.tValue) == 0:
        return

    eventPlayer.tValue = eventPlayer.tValue[0]

    if eventPlayer.tValue[Item.REMOVE_ON_STATE] > 0 and eventPlayer.tValue[Item.STATE] >= eventPlayer.tValue[Item.REMOVE_ON_STATE]:
        return
        
    eventPlayer.tIndex = eventPlayer.itemIds.index(eventPlayer.tValue[Item.ID])

    if eventPlayer.tValue[Item.STATE] < len(eventPlayer.tValue[Item.MESSAGE]):
        smallMessage(eventPlayer, eventPlayer.tValue[Item.MESSAGE][eventPlayer.tValue[Item.STATE]])
        if eventPlayer.tValue[Item.ITEM_NAME]:
            if eventPlayer.tValue[Item.PLAY_GET_SOUND]:
                playGetItem()
            eventPlayer.inventory = eventPlayer.tValue[Item.ITEM_NAME].concat(eventPlayer.inventory)
            # wait needed to allow time for message to show before incrementing state (dumb)
            wait(1)
            eventPlayer.tValue[Item.STATE]++
            eventPlayer.itemPoints[eventPlayer.tIndex] = eventPlayer.tValue
        else:
            if eventPlayer.tValue[Item.PLAY_GET_SOUND]:
                playNoItem()
    elif eventPlayer.tValue[Item.MESSAGE]:
        playNoItem()
        smallMessage(eventPlayer, NOTHING_LEFT_MESSAGE)

    # special interactions

    if eventPlayer.wiresConnected and eventPlayer.generatorOn and not eventPlayer.lightsOn:
        if eventPlayer.tValue[Item.ID] == "innerSwitch1":
            TOGGLE_POWER_SWITCH(eventPlayer, 4)
            TOGGLE_POWER_SWITCH(eventPlayer, 0)
            TOGGLE_POWER_SWITCH(eventPlayer, 1)
            makeSwitchNoise()
            checkPowerPanel()
        elif eventPlayer.tValue[Item.ID] == "innerSwitch2":
            TOGGLE_POWER_SWITCH(eventPlayer, 0)
            TOGGLE_POWER_SWITCH(eventPlayer, 1)
            TOGGLE_POWER_SWITCH(eventPlayer, 2)
            makeSwitchNoise()
            checkPowerPanel()
        elif eventPlayer.tValue[Item.ID] == "innerSwitch3":
            TOGGLE_POWER_SWITCH(eventPlayer, 1)
            TOGGLE_POWER_SWITCH(eventPlayer, 2)
            TOGGLE_POWER_SWITCH(eventPlayer, 3)
            makeSwitchNoise()
            checkPowerPanel()
        elif eventPlayer.tValue[Item.ID] == "innerSwitch4":
            TOGGLE_POWER_SWITCH(eventPlayer, 2)
            TOGGLE_POWER_SWITCH(eventPlayer, 3)
            TOGGLE_POWER_SWITCH(eventPlayer, 4)
            makeSwitchNoise()
            checkPowerPanel()
        elif eventPlayer.tValue[Item.ID] == "innerSwitch5":
            TOGGLE_POWER_SWITCH(eventPlayer, 3)
            TOGGLE_POWER_SWITCH(eventPlayer, 4)
            TOGGLE_POWER_SWITCH(eventPlayer, 0)
            makeSwitchNoise()
            checkPowerPanel()

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
    elif eventPlayer.tValue[Item.ID] == "barnSafe2":
        eventPlayer.canLeaveBarn = true
    elif eventPlayer.tValue[Item.ID] == "barnPaperClue1":
        smallMessage(eventPlayer, "{0} {1} _ _ _".format(eventPlayer.barnCode[0], eventPlayer.barnCode[1]))
    elif eventPlayer.tValue[Item.ID] == "barnPaperClue2":
        smallMessage(eventPlayer, "_ _ _ {0} {1}".format(eventPlayer.barnCode[3], eventPlayer.barnCode[4]))

# Apply
#!define CANT_APPLY_MESSAGE random.choice(["You can't use that thing with this thing", "You can't use that thing with this thing", "You can't use that thing with this thing", \
"It would be disasterous to use those two things together", "Trying to use those together would be unmitigated poppycock", "Are you just trying every possible combination?", \
"Some things were not meant to mix. Specifically these two.", "Only an amateur would use that in this way, which you are not", "You contemplate trying to force these things together, but decide against it", \
"To join these two would be a most unholy matrimony", "You're as willing as the next man to perform an experiment, but not this one"])
#!define NO_ITEM_MESSAGE random.choice(["You don't have anything to use", "You don't have anything to use", "You don't have anything to use", \
"Your hands are empty", "Your hands are empty", "Your hands are empty", "You try punching it, but nothing happens"])

#!define SHOULD_APPLY_ITEM(eventPlayer, key) (eventPlayer.key[Item.STATE] < len(eventPlayer.key[Item.REQUIRED_ITEM]) and eventPlayer.inventory[0] == eventPlayer.key[Item.REQUIRED_ITEM][eventPlayer.key[Item.STATE]])

#!define APPLY_ITEM_SUCCESS(eventPlayer, item) smallMessage(eventPlayer, item[Item.SUCCESS_MESSAGE][item[Item.STATE] - 1])
def APPLY_ITEM_FAIL():
    if len(eventPlayer.inventory) == 0:
        smallMessage(eventPlayer, NO_ITEM_MESSAGE)
    else:
        smallMessage(eventPlayer, CANT_APPLY_MESSAGE)

rule "Apply":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if SHOULD_INTERACT(eventPlayer, eventPlayer.tutGate1) or SHOULD_INTERACT(eventPlayer, eventPlayer.tutGate2):
        eventPlayer.tValue = GET_ITEM_ENTRY(eventPlayer, "tutGate1")
        if eventPlayer.tValue[Item.STATE] == 0:
            if SHOULD_APPLY_ITEM(eventPlayer, tutGate1):
                INCREMENT_STATE(eventPlayer, "tutGate2")
                eventPlayer.tValue = GET_ITEM_ENTRY(eventPlayer, "tutGate1")
                eventPlayer.tValue[Item.STATE]++
                SAVE_STATE(eventPlayer, eventPlayer.tValue)

                APPLY_ITEM_SUCCESS(eventPlayer, eventPlayer.tValue)
                del eventPlayer.inventory[0]
                playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, null, eventPlayer, 100)
                eventPlayer.tutorialFinished = true
            else:
                APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer, eventPlayer.innerWires):
        if SHOULD_APPLY_ITEM(eventPlayer, innerWires):
            INCREMENT_STATE(eventPlayer, "innerWires")
            APPLY_ITEM_SUCCESS(eventPlayer, eventPlayer.tValue)
            innerWirePlayers.append(eventPlayer)
            eventPlayer.wiresConnected = true
            del eventPlayer.inventory[0]
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer, eventPlayer.innerBarrel2):
        if SHOULD_APPLY_ITEM(eventPlayer, innerBarrel2):
            INCREMENT_STATE(eventPlayer, "innerBarrel2")
            APPLY_ITEM_SUCCESS(eventPlayer, eventPlayer.tValue)
            del eventPlayer.inventory[0]
            eventPlayer.inventory = "Filled petrol can".concat(eventPlayer.inventory)
            createEffect(eventPlayer, Effect.MOIRA_ORB_HEAL_SOUND, null, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            pushEffectDeleteQueue()
            wait(2)
            popEffectDeleteQueue()
        else:
            APPLY_ITEM_FAIL()
    elif SHOULD_INTERACT(eventPlayer, eventPlayer.innerGenerator):
        if SHOULD_APPLY_ITEM(eventPlayer, innerGenerator):
            INCREMENT_STATE(eventPlayer, "innerGenerator")
            APPLY_ITEM_SUCCESS(eventPlayer, eventPlayer.tValue)
            del eventPlayer.inventory[0]
            createEffect(eventPlayer, Effect.MOIRA_ORB_HEAL_SOUND, null, eventPlayer, 100, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            pushEffectDeleteQueue()
            wait(2)
            popEffectDeleteQueue()
            eventPlayer.generatorOn = true
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
        eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 9999)
        eventPlayer.setHealth(200)
    while RULE_CONDITION
    eventPlayer.setMoveSpeed(100)

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

    MAKE_WALL(eventPlayer, vect(-85.53, 10.44, -97.39), vect(-85, 14.38, -94.87), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-104.47, 5.37, -128.85), vect(-99.85, 12.44, -107.17), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-103.34, 6.04, -140.02), vect(-102.20, 16.33, -134.55), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-99.65, 12.44, -153.76), vect(-102.71, 16, -149.09), DARK_AND_SCARY_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-97.29, 12.44, -169.53), vect(-96.75, 16, -166.99), DARK_AND_SCARY_MESSAGE)

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

#!define SCRAPYARD_OUTSIDE_MESSAGE "The sun is too bright for your sensitive skin"

rule "Create sunlight barriers":
    @Event eachPlayer
    @Condition eventPlayer.isJunk
    @Condition eventPlayer.lightsOn
    @Condition not eventPlayer.canGoOutside

    MAKE_WALL(eventPlayer, vect(-37.91, 13.26, -123.26), vect(-41.45, 16.37, -122.51), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-46.03, 7.37, -113.09), vect(-49.96, 11.37, -112.03), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-65.11, 7.43, -101.49), vect(-63.95, 11.43, -96.06), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-52.07, 13.51, -116.27), vect(-51.45, 16.35, -113.52), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-56.23, 14.48, -110.34), vect(-62.38, 17.43, -109.05), SCRAPYARD_OUTSIDE_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-68.33, 12.43, -103.68), vect(-73.34, 17.6, -102.63), SCRAPYARD_OUTSIDE_MESSAGE)

    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Barn outside wall

#!define BARN_OUTSIDE_MESSAGE "You could never leave the house without your little buddy"

rule "Create barn outside wall":
    @Event eachPlayer
    @Condition eventPlayer.isHog
    @Condition not eventPlayer.canLeaveBarn

    MAKE_WALL(eventPlayer, vect(43.16, 16, -72.95), vect(46.87, 19, -73.26), BARN_OUTSIDE_MESSAGE)
    MAKE_WALL(eventPlayer, vect(43.08, 10, -74.13), vect(42.65, 12.75, -78.85), BARN_OUTSIDE_MESSAGE)
    MAKE_WALL(eventPlayer, vect(49.50, 10, -91.89), vect(49.17, 13, -95.62), BARN_OUTSIDE_MESSAGE)
    
    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START

# Barn secret wall

rule "Create barn secret wall":
    @Event eachPlayer
    @Condition eventPlayer.isHog
    @Condition not eventPlayer.canAccessBarnSecret

    MAKE_WALL(eventPlayer, vect(55.83, 9, -65.80), vect(52.28, 11.81, -65.50), "Enter the code first!")

    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START


# Junkertown entry wall

#!define JUNKERTOWN_WALL_MESSAGE "The Queen isn't too keen on you coming back after what happened last time"

rule "Junkertown entry wall":
    @Event eachPlayer
    @Condition eventPlayer.isHog
    @Condition eventPlayer.canLeaveBarn

    MAKE_WALL(eventPlayer, vect(-50.22, 4.35, -41.54), vect(-48.34, 8.47, -47.74), JUNKERTOWN_WALL_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-48.99, 9.49, -46.47), vect(-47.91, 13.48, -50.19), JUNKERTOWN_WALL_MESSAGE)
    MAKE_WALL(eventPlayer, vect(-28.33, 4.48, -64.23), vect(-25.17, 8.48, -66.02), JUNKERTOWN_WALL_MESSAGE)

    wait(0.016, Wait.ABORT_WHEN_FALSE)
    goto RULE_START



# DEBUG FUNCTIONS
globalvar debugPlayers = []

playervar pointHelperEffect
playervar pointHelperHud
playervar pointHelperState = 0

def printText():
    hudHeader(eventPlayer, A, HudPosition.TOP, 0, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    for I in range(strLen("test 123")):

#!define BLACK_SCREEN_POS vect(34, 6, -88)
#!define BLACK_SCREEN_FACING vect(0, -1, 0)
#!define FADE_TO_BLACK() eventPlayer.startCamera(BLACK_SCREEN_POS, BLACK_SCREEN_POS + BLACK_SCREEN_FACING, 0)

rule "cam test":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.isHoldingButton(Button.ABILITY_1)

    eventPlayer.disableHeroHUD()

    FADE_TO_BLACK()
    wait(2)

    bigMessage(eventPlayer, "You had a plan")
    wait(4)
    
    eventPlayer.startCamera(vect(45.98, 11.12, -71.48), vect(45.98, 11.12, -71.48) + vect(-1, -0.01, 0.10), 0)
    wait(2)

    FADE_TO_BLACK()
    wait(1)

    bigMessage(eventPlayer, "The plan did a thing")
    wait(4)

    # createInWorldText(eventPlayer, )
    # eventPlayer.effectDeleteQueue.append(getLastCreatedText())

    # wait(10)

    # destroyHudText(eventPlayer.effectDeleteQueue[0])
    # del eventPlayer.effectDeleteQueue[0]
    eventPlayer.stopCamera()
    eventPlayer.enableHeroHud()

rule "Debug on":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.isHoldingButton(Button.ULTIMATE)

    if eventPlayer in debugPlayers:
        debugPlayers.remove(eventPlayer)
    else:
        debugPlayers.append(eventPlayer)

rule "Be mercy":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.JUMP) and eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.startForcingHero(Hero.MERCY)

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

    for eventPlayer.I in range(len(eventPlayer.itemPoints)):
        if strContains(eventPlayer.itemPoints[eventPlayer.I][Item.ID], "barn"):
            createEffect(debugPlayers, Effect.SPHERE, Color.PURPLE, eventPlayer.itemPoints[eventPlayer.I][Item.POINT], eventPlayer.itemPoints[eventPlayer.I][Item.RADIUS], EffectReeval.VISIBILITY)

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
    hudHeader(eventPlayer, "facing: {0}".format(eventPlayer.getFacingDirection()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(eventPlayer, "is outside: {0}".format(eventPlayer.inSunlight), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(eventPlayer, "inv: {0}".format(eventPlayer.inventory), HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    hudHeader(eventPlayer, "load {0}".format(getServerLoad()), HudPosition.RIGHT, 0, Color.RED, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "peak {0}".format(getPeakServerLoad()), HudPosition.RIGHT, 1, Color.RED, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "avg {0}".format(getAverageServerLoad()), HudPosition.RIGHT, 2, Color.RED, HudReeval.STRING, SpecVisibility.NEVER)
