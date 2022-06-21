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
            "gamemodeStartTrigger": "manual",
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
                "enableAbility1": false,
                "jumpVerticalSpeed%": 250,
                "movementSpeed%": 200,
                "enableInfiniteAmmo": true,
                "enablePrimaryFire": false,
                "enableMelee": false,
                "enablePassive": false,
                "enableAbility2": false,
                "enableSpawningWithUlt": true,
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

#!define POINTER_COLOR Color.WHITE
#!define MAIN_POINT_COLOR Color.GREEN
#!define OFF_POINT_FIRST_COLOR Color.YELLOW
#!define OFF_POINT_SECOND_COLOR Color.ORANGE
#!define EDIT_COLOR Color.ORANGE
#!define PREVIEW_COLOR Color.TURQUOISE

playervar pointerDistance = 3
playervar pointRadius = 0.2

globalvar visibility = []

playervar points = []
playervar pointsText = []
playervar pointsEffect = []
playervar handleEffects = []
playervar isAddingPoints = true
playervar isEditingPoints = false
playervar pointerPos
playervar pointerEffect
playervar editingPointPos
playervar editingPointIndex
playervar editingPointEffect
playervar editingCleanup = false

playervar arg

playervar last1Point
playervar last2Point
playervar last3Point
playervar next1Point
playervar next2Point

playervar showPointer = null
playervar pointerPosition

playervar bezier
playervar bezierDuration = 5

playervar doCamera = false
playervar isMercyUlting = false

# Add point: left click
# Edit point: right click
# Remove last points: R
# view camera: shift + E

rule "Player join":
    @Event playerJoined

    eventPlayer.startForcingHero(Hero.MERCY)
    createEffect(visibility, Effect.SPHERE, POINTER_COLOR, updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * eventPlayer.pointerDistance), eventPlayer.pointRadius, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.pointerEffect = getLastCreatedEntity()
    hudHeader(eventPlayer, "add point: left click", HudPosition.LEFT, 0, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "edit point: right click", HudPosition.LEFT, 1, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "remove last point: r", HudPosition.LEFT, 2, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "preview curve: f + v", HudPosition.LEFT, 3, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "view curve: f + e", HudPosition.LEFT, 4, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "all view curve: f + e + shift", HudPosition.LEFT, 5, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "increase duration: f + left click", HudPosition.LEFT, 6, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "decrease duration: f + right click", HudPosition.LEFT, 7, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "segment duration: {0}".format(eventPlayer.bezierDuration), HudPosition.LEFT, 10, Color.PURPLE, HudReeval.STRING, SpecVisibility.NEVER)

    # hudHeader(eventPlayer, "avg load: {0}".format(getAverageServerLoad()), HudPosition.RIGHT, 10, Color.ORANGE, HudReeval.STRING, SpecVisibility.NEVER)
    # hudHeader(eventPlayer, "peak load: {0}".format(getPeakServerLoad()), HudPosition.RIGHT, 11, Color.ORANGE, HudReeval.STRING, SpecVisibility.NEVER)
    # hudHeader(eventPlayer, "load: {0}".format(getServerLoad()), HudPosition.RIGHT, 12, Color.ORANGE, HudReeval.STRING, SpecVisibility.NEVER)

    wait(1)

    visibility.append(eventPlayer)

rule "Noclip start":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    eventPlayer.disableEnvironmentCollision(false)

rule "Noclip end":
    @Event eachPlayer
    @Condition not eventPlayer.isHoldingButton(Button.MELEE)

    eventPlayer.enableEnvironmentCollision()

rule "Mercy ult":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)

    eventPlayer.isMercyUlting = not eventPlayer.isMercyUlting

    if eventPlayer.isMercyUlting:
        # eventPlayer.setUltCharge(100)
        # eventPlayer.forceButtonPress(Button.ULTIMATE)
    else:
        eventPlayer.startForcingHero(Hero.PHARAH)
        wait(0.1)
        eventPlayer.startForcingHero(Hero.MERCY)

rule "Mercy ult":
    @Event eachPlayer
    @Condition eventPlayer.isMercyUlting and not eventPlayer.isUsingUltimate()

    eventPlayer.setUltCharge(100)
    eventPlayer.forceButtonPress(Button.ULTIMATE)

def createHud():
    while len(eventPlayer.pointsText) > 0:
        destroyHudText(eventPlayer.pointsText[0])
        del eventPlayer.pointsText[0]

    for eventPlayer.I in range(len(eventPlayer.points)):
        hudHeader(eventPlayer, "{0}".format(eventPlayer.points[eventPlayer.I]), HudPosition.RIGHT, eventPlayer.I + 1, Color.WHITE, HudReeval.NONE, SpecVisibility.NEVER)
        eventPlayer.pointsText.append(getLastCreatedText())

def createHandles():
    while len(eventPlayer.handleEffects) > 0:
        destroyEffect(eventPlayer.handleEffects[0])
        del eventPlayer.handleEffects[0]

    for eventPlayer.I in range(0, len(eventPlayer.points), 3):
        if eventPlayer.I - 1 >= 0:
            createBeam(visibility, Beam.GRAPPLE, eventPlayer.points[eventPlayer.I - 1], eventPlayer.points[eventPlayer.I], null, EffectReeval.VISIBILITY)
            eventPlayer.handleEffects.append(getLastCreatedEntity())

        if eventPlayer.I + 1 < len(eventPlayer.points):
            createBeam(visibility, Beam.GRAPPLE, eventPlayer.points[eventPlayer.I], eventPlayer.points[eventPlayer.I + 1], null, EffectReeval.VISIBILITY)
            eventPlayer.handleEffects.append(getLastCreatedEntity())

# The index to redo should be stored in eventPlayer.arg
def redoCurve():
    eventPlayer.points[eventPlayer.arg + 1] = 2 * eventPlayer.points[eventPlayer.arg] - eventPlayer.points[eventPlayer.arg - 1]
    eventPlayer.points[eventPlayer.arg + 2] = eventPlayer.points[eventPlayer.arg - 2] + 2 * eventPlayer.points[eventPlayer.arg + 1] - 2 * eventPlayer.points[eventPlayer.arg - 1]

def redoAllCurves():
    for eventPlayer.I in range(0, len(eventPlayer.points), 3):
        if eventPlayer.I != 0:
            eventPlayer.arg = eventPlayer.I
            redoCurve()

def createPoints():
    while len(eventPlayer.pointsEffect) > 0:
        destroyEffect(eventPlayer.pointsEffect[0])
        del eventPlayer.pointsEffect[0]

    for eventPlayer.E in range(len(eventPlayer.points)):
        if eventPlayer.E % 3 == 0:
            createEffect(visibility, Effect.SPHERE, MAIN_POINT_COLOR, eventPlayer.points[eventPlayer.E], eventPlayer.pointRadius, EffectReeval.VISIBILITY)
        elif eventPlayer.E % 3 == 1:
            createEffect(visibility, Effect.SPHERE, OFF_POINT_SECOND_COLOR, eventPlayer.points[eventPlayer.E], eventPlayer.pointRadius * 0.5, EffectReeval.VISIBILITY)
        else:
            createEffect(visibility, Effect.SPHERE, OFF_POINT_FIRST_COLOR, eventPlayer.points[eventPlayer.E], eventPlayer.pointRadius * 0.5, EffectReeval.VISIBILITY)
        eventPlayer.pointsEffect.append(getLastCreatedEntity())

rule "Add point":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and not eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and not eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.editingPointPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * eventPlayer.pointerDistance

    eventPlayer.points.append(eventPlayer.editingPointPos)

    createHud()
    redoAllCurves()
    createPoints()
    createHandles()

rule "Remove last point":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and not eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    if len(eventPlayer.points) > 4:
        del eventPlayer.points[len(eventPlayer.points) - 1]
        # destroyEffect(eventPlayer.pointsEffect[len(eventPlayer.pointsEffect) - 1])
        # del eventPlayer.pointsEffect[len(eventPlayer.pointsEffect) - 1]
        
        del eventPlayer.points[len(eventPlayer.points) - 1]
        # destroyEffect(eventPlayer.pointsEffect[len(eventPlayer.pointsEffect) - 1])
        # del eventPlayer.pointsEffect[len(eventPlayer.pointsEffect) - 1]

    del eventPlayer.points[len(eventPlayer.points) - 1]
    # destroyEffect(eventPlayer.pointsEffect[len(eventPlayer.pointsEffect) - 1])
    # del eventPlayer.pointsEffect[len(eventPlayer.pointsEffect) - 1]

    createHud()
    redoAllCurves()
    createPoints()
    createHandles()

rule "Start edit point":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and not eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and not eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.editingPointPos = [e for e in eventPlayer.points if distance(e, eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * distance(eventPlayer.getEyePosition(), e)) <= eventPlayer.pointRadius]

    if len(eventPlayer.editingPointPos) == 0:
        return

    eventPlayer.editingPointPos = eventPlayer.editingPointPos[0]
    eventPlayer.editingPointIndex = eventPlayer.points.index(eventPlayer.editingPointPos)

    if eventPlayer.editingPointIndex > 3 and eventPlayer.editingPointIndex % 3 != 0:
        playEffect(eventPlayer, DynamicEffect.EXPLOSION_SOUND, null, eventPlayer, 30)
        return

    eventPlayer.isEditingPoints = true

    createEffect(eventPlayer, Effect.SPHERE, EDIT_COLOR, updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * eventPlayer.pointerDistance), eventPlayer.pointRadius, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    eventPlayer.editingPointEffect = getLastCreatedEntity()

rule "End edit point":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.editingPointPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * eventPlayer.pointerDistance

    # replace value in points array
    eventPlayer.points[eventPlayer.editingPointIndex] = eventPlayer.editingPointPos

    createHud()
    redoAllCurves()
    createPoints()
    createHandles()

    destroyEffect(eventPlayer.editingPointEffect)
    eventPlayer.editingCleanup = true

rule "Editing cleanup":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and eventPlayer.isEditingPoints and eventPlayer.editingCleanup
    @Condition not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.isEditingPoints = false
    eventPlayer.editingCleanup = false

rule "Inc duration":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.bezierDuration += 0.1
    
rule "Dec duration":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.bezierDuration -= 0.1

# uses the four points in eventplayer.bezier, and duration from eventplayer.bezierDuration
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

    # X + (Y - X) * S

rule "Do curve preview":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.MELEE)

    # A = X + (Y - X) * T
    # B = Y + (Z - Y) * T
    # point = A + (B - A) * T
    # point = (X + (Y - X) * T) + ((Y + (Z - Y) * T) - (X + (Y - X) * T)) * T

    # eventPlayer.isEditingPoints = false

    createEffect(visibility, Effect.SPHERE, PREVIEW_COLOR, updateEveryTick((eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T) + ((eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T) - (eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T)) * eventPlayer.T), 0.2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    for eventPlayer.I in range(0, len(eventPlayer.points) - 3, 3):
        eventPlayer.bezier = eventPlayer.points.slice(eventPlayer.I, 4)
        doBezier()
        wait(eventPlayer.bezierDuration)

    destroyEffect(getLastCreatedEntity())

    # eventPlayer.isEditingPoints = true


rule "Do curve camera":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ABILITY_2)

    visibility.remove(eventPlayer)

    eventPlayer.startCamera((eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T) + ((eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T) - (eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T)) * eventPlayer.T, eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T, 0)

    for eventPlayer.I in range(0, len(eventPlayer.points) - 3, 3):
        eventPlayer.bezier = eventPlayer.points.slice(eventPlayer.I, 4)
        doBezier()
        wait(eventPlayer.bezierDuration)

    eventPlayer.stopCamera()

    visibility.append(eventPlayer)

rule "Do curve camera for everyone":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ABILITY_2) and eventPlayer.isHoldingButton(Button.ABILITY_1)

    getAllPlayers().startCamera((eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T) + ((eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T) - (eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T)) * eventPlayer.T, eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T, 0)

    for eventPlayer.I in range(0, len(eventPlayer.points) - 3, 3):
        eventPlayer.bezier = eventPlayer.points.slice(eventPlayer.I, 4)
        doBezier()
        wait(eventPlayer.bezierDuration)

    getAllPlayers().stopCamera()

# rule "make square":
#     @Event eachPlayer
#     @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ABILITY_2)

#     eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
#     wait(0.25)
#     eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

#     eventPlayer.teleport(eventPlayer.getPosition() + vect(0, 0, 10))
#     wait(0.25)
#     eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
#     wait(0.25)
#     eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

#     eventPlayer.teleport(eventPlayer.getPosition() + vect(20, 0, 0))
#     wait(0.25)
#     eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
#     wait(0.25)
#     eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

#     eventPlayer.teleport(eventPlayer.getPosition() + vect(0, 0, -20))
#     wait(0.25)
#     eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
#     wait(0.25)
#     eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

#     eventPlayer.teleport(eventPlayer.getPosition() + vect(-20, 0, 0))
#     wait(0.25)
#     eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
#     wait(0.25)
#     eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)

#     eventPlayer.teleport(eventPlayer.getPosition() + vect(0, 0, 20))
#     wait(0.25)
#     eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
#     wait(0.25)
#     eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
