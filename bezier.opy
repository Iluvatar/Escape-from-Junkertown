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

#!extension playMoreEffects

#!define POINTER_COLOR Color.WHITE
#!define MAIN_POINT_COLOR Color.GREEN
#!define OFF_POINT_FIRST_COLOR Color.YELLOW
#!define OFF_POINT_SECOND_COLOR Color.ORANGE
#!define EDIT_COLOR Color.ORANGE
#!define PREVIEW_COLOR Color.TURQUOISE

#!define PAUSE_NUM 10

playervar pointerDistance = 3
playervar pointRadius = 0.2

globalvar visibility = []
globalvar textVisibility = []
globalvar textVisibilityHolder

playervar points1d
playervar p1
playervar p2
playervar segments1X
playervar segments2X
playervar segments1Y
playervar segments2Y
playervar segments1Z
playervar segments2Z
playervar segments1
playervar segments2

playervar points = []
playervar pointsText = []
playervar pointsEffect = []
playervar handleEffects = []
playervar isAddingPoints = true
playervar isEditingPoints = false
playervar pointerPos
playervar pointerColor = POINTER_COLOR
playervar pointerEffect
playervar editingPointPos
playervar editingPointIndex
playervar editingCleanup = false
playervar previewEntity
playervar liveRenderDisabled = true
playervar hasChanged = false

playervar lastText
playervar liveRenderText

playervar last1Point
playervar last2Point
playervar last3Point
playervar next1Point
playervar next2Point

playervar showPointer = null
playervar pointerPosition

playervar bezier
playervar bezierDuration = 2

playervar doCamera = false
playervar isMercyUlting = false

def addInitialPoints():
    eventPlayer.points = [
        vect(-49.22, 33.22, -113.27),
        vect(-48.46, 40.97, -111.93),
        vect(-48.53, 49.74, -112.06),
        vect(-49.03, 56.91, -113.07),
        vect(-50.43, 65.20, -115.66),
    ]
    for eventPlayer.J in range(len(eventPlayer.points)):
        createEffect(visibility, Effect.ORB, MAIN_POINT_COLOR, eventPlayer.points[eventPlayer.J], eventPlayer.pointRadius, EffectReeval.VISIBILITY)
        eventPlayer.pointsEffect.append(getLastCreatedEntity())

    eventPlayer.hasChanged = true


def renderHandles():
    while len(eventPlayer.handleEffects) > 0:
        destroyEffect(eventPlayer.handleEffects[0])
        del eventPlayer.handleEffects[0]

    for eventPlayer.I in range(len(eventPlayer.points) - 1):
        createBeam(visibility, Beam.GRAPPLE, eventPlayer.points[eventPlayer.I], eventPlayer.segments1[eventPlayer.I], null, EffectReeval.VISIBILITY)
        eventPlayer.handleEffects.append(getLastCreatedEntity())
        createBeam(visibility, Beam.GRAPPLE, eventPlayer.points[eventPlayer.I + 1], eventPlayer.segments2[eventPlayer.I], null, EffectReeval.VISIBILITY)
        eventPlayer.handleEffects.append(getLastCreatedEntity())

# uses values from eventPlayer.points1d
def computeSegments():
    eventPlayer.N = len(eventPlayer.points1d) - 1
    eventPlayer.A = [0]
    eventPlayer.B = [2]
    eventPlayer.C = [1]
    eventPlayer.R = [eventPlayer.points1d[0] + 2 * eventPlayer.points1d[1]]

    for eventPlayer.I in range(1, eventPlayer.N - 1):
        eventPlayer.A.append(1)
        eventPlayer.B.append(4)
        eventPlayer.C.append(1)
        eventPlayer.R.append(4 * eventPlayer.points1d[eventPlayer.I] + 2 * eventPlayer.points1d[eventPlayer.I + 1])
        if (eventPlayer.I + 1) % PAUSE_NUM == 0:
            wait(0.1)

    eventPlayer.A.append(2)
    eventPlayer.B.append(7)
    eventPlayer.C.append(0)
    eventPlayer.R.append(8 * eventPlayer.points1d[eventPlayer.N - 1] + eventPlayer.points1d[eventPlayer.N])

    for eventPlayer.I in range(1, eventPlayer.N):
        eventPlayer.M = eventPlayer.A[eventPlayer.I] / eventPlayer.B[eventPlayer.I - 1]
        eventPlayer.B[eventPlayer.I] -= eventPlayer.M * eventPlayer.C[eventPlayer.I - 1]
        eventPlayer.R[eventPlayer.I] -= eventPlayer.M * eventPlayer.R[eventPlayer.I - 1]
        if (eventPlayer.I + 1) % PAUSE_NUM == 0:
            wait(0.1)

    eventPlayer.p1 = []
    eventPlayer.p1[eventPlayer.N - 1] = eventPlayer.R[eventPlayer.N - 1] / eventPlayer.B[eventPlayer.N - 1]
    for eventPlayer.I in range(eventPlayer.N - 2, -1, -1):
        eventPlayer.p1[eventPlayer.I] = (eventPlayer.R[eventPlayer.I] - eventPlayer.C[eventPlayer.I] * eventPlayer.p1[eventPlayer.I + 1]) / eventPlayer.B[eventPlayer.I]
        if (eventPlayer.N - 2 - eventPlayer.I + 1) % PAUSE_NUM == 0:
            wait(0.1)

    eventPlayer.p2 = []
    for eventPlayer.I in range(eventPlayer.N - 1):
        eventPlayer.p2.append(2 * eventPlayer.points1d[eventPlayer.I + 1] - eventPlayer.p1[eventPlayer.I + 1])
        if (eventPlayer.I + 1) % PAUSE_NUM == 0:
            wait(0.1)
    eventPlayer.p2.append((eventPlayer.points1d[eventPlayer.N] + eventPlayer.p1[eventPlayer.N - 1]) / 2)

def computeAllSegments():
    hudHeader(eventPlayer, "RENDERING", HudPosition.TOP, 1, Color.RED, HudReeval.NONE, SpecVisibility.NEVER)
    eventPlayer.lastText = getLastCreatedText()

    # compute x components
    eventPlayer.points1d = [e.x for e in eventPlayer.points]
    computeSegments()
    eventPlayer.segments1X = eventPlayer.p1
    eventPlayer.segments2X = eventPlayer.p2

    # compute y components
    eventPlayer.points1d = [e.y for e in eventPlayer.points]
    computeSegments()
    eventPlayer.segments1Y = eventPlayer.p1
    eventPlayer.segments2Y = eventPlayer.p2

    # compute z components
    eventPlayer.points1d = [e.z for e in eventPlayer.points]
    computeSegments()
    eventPlayer.segments1Z = eventPlayer.p1
    eventPlayer.segments2Z = eventPlayer.p2

    eventPlayer.segments1 = [vect(eventPlayer.segments1X[i], eventPlayer.segments1Y[i], eventPlayer.segments1Z[i]) for e, i in eventPlayer.segments1X]
    eventPlayer.segments2 = [vect(eventPlayer.segments2X[i], eventPlayer.segments2Y[i], eventPlayer.segments2Z[i]) for e, i in eventPlayer.segments2X]

    destroyHudText(eventPlayer.lastText)
    eventPlayer.hasChanged = false

    renderHandles()

rule "Create help text":
    hudHeader(textVisibility, "add point: left click", HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "add point at eye position: shift + left click", HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "edit point: right click", HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "remove last point: f + r", HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "remove all points: shift + f + r", HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "preview curve: f + v", HudPosition.LEFT, 5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "view curve: f + e", HudPosition.LEFT, 6, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "all view curve: shift + f + e", HudPosition.LEFT, 7, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "toggle live render: f + space", HudPosition.LEFT, 8, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "decrease duration: f + left click", HudPosition.LEFT, 9, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "increase duration: f + right click", HudPosition.LEFT, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "export points: shift + f + v", HudPosition.LEFT, 11, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "restart: ctrl + r", HudPosition.LEFT, 12, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(textVisibility, "toggle text: shift + ctrl + space", HudPosition.LEFT, 13, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

    hudHeader(getAllPlayers(), "avg load: {0}".format(getAverageServerLoad()), HudPosition.RIGHT, 10, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(getAllPlayers(), "peak load: {0}".format(getPeakServerLoad()), HudPosition.RIGHT, 11, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudHeader(getAllPlayers(), "load: {0}".format(getServerLoad()), HudPosition.RIGHT, 12, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

rule "Player join":
    @Event playerJoined

    eventPlayer.startForcingHero(Hero.MERCY)
    createEffect(visibility, Effect.SPHERE, eventPlayer.pointerColor, updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * eventPlayer.pointerDistance), eventPlayer.pointRadius, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
    eventPlayer.pointerEffect = getLastCreatedEntity()

    textVisibility.append(eventPlayer)
    hudHeader(eventPlayer, "segment duration: {0}".format(eventPlayer.bezierDuration), HudPosition.LEFT, 20, Color.PURPLE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "{0} points in line".format(len(eventPlayer.points)), HudPosition.RIGHT, 1, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)
    hudHeader(eventPlayer, "facing: {0}".format(eventPlayer.getFacingDirection()), HudPosition.RIGHT, 2, Color.WHITE, HudReeval.STRING, SpecVisibility.NEVER)

    wait(1)

    addInitialPoints()

    visibility.append(eventPlayer)
    eventPlayer.disableGamemodeHud()

rule "Toggle text":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.JUMP)

    if eventPlayer in textVisibility:
        textVisibility.remove(eventPlayer)
    else:
        textVisibility.append(eventPlayer)

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

    # if eventPlayer.isMercyUlting:
    #     # eventPlayer.setUltCharge(100)
    #     # eventPlayer.forceButtonPress(Button.ULTIMATE)
    # else:
    #     eventPlayer.startForcingHero(Hero.PHARAH)
    #     wait(0.1)
    #     eventPlayer.startForcingHero(Hero.MERCY)

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

rule "Add point at cursor":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and not eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and not eventPlayer.isHoldingButton(Button.INTERACT)

    if eventPlayer.isHoldingButton(Button.ABILITY_1):
        eventPlayer.editingPointPos = eventPlayer.getEyePosition()
    else:
        eventPlayer.editingPointPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * eventPlayer.pointerDistance

    eventPlayer.points.append(eventPlayer.editingPointPos)
    createEffect(visibility, Effect.ORB, MAIN_POINT_COLOR, eventPlayer.editingPointPos, eventPlayer.pointRadius, EffectReeval.VISIBILITY)
    eventPlayer.pointsEffect.append(getLastCreatedEntity())

    eventPlayer.hasChanged = true
    if not eventPlayer.liveRenderDisabled:
        computeAllSegments()

rule "Remove last point":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and not eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.RELOAD) and not eventPlayer.isHoldingButton(Button.ABILITY_1)

    del eventPlayer.points[len(eventPlayer.points) - 1]
    destroyEffect(eventPlayer.pointsEffect[len(eventPlayer.points)])
    del eventPlayer.pointsEffect[len(eventPlayer.points)]
    destroyEffect(eventPlayer.handleEffects[len(eventPlayer.handleEffects) - 1])
    del eventPlayer.handleEffects[len(eventPlayer.handleEffects) - 1]
    destroyEffect(eventPlayer.handleEffects[len(eventPlayer.handleEffects) - 1])
    del eventPlayer.handleEffects[len(eventPlayer.handleEffects) - 1]

    eventPlayer.hasChanged = true
    if not eventPlayer.liveRenderDisabled:
        computeAllSegments()

rule "Remove all points":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and not eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.RELOAD) and eventPlayer.isHoldingButton(Button.ABILITY_1)

    eventPlayer.points = []
    while len(eventPlayer.pointsEffect) > 0:
        destroyEffect(eventPlayer.pointsEffect[0])
        del eventPlayer.pointsEffect[0]

    while len(eventPlayer.handleEffects) > 0:
        destroyEffect(eventPlayer.handleEffects[0])
        del eventPlayer.handleEffects[0]

    eventPlayer.hasChanged = true
    if not eventPlayer.liveRenderDisabled:
        computeAllSegments()

rule "Start edit point":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and not eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and not eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.editingPointPos = [e for e in eventPlayer.points if distance(e, eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * distance(eventPlayer.getEyePosition(), e)) <= eventPlayer.pointRadius]

    if len(eventPlayer.editingPointPos) == 0:
        return

    eventPlayer.editingPointPos = eventPlayer.editingPointPos[0]
    eventPlayer.editingPointIndex = eventPlayer.points.index(eventPlayer.editingPointPos)

    eventPlayer.isEditingPoints = true

    eventPlayer.pointerColor = EDIT_COLOR

rule "End edit point":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and eventPlayer.isEditingPoints
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if eventPlayer.isHoldingButton(Button.ABILITY_1):
        eventPlayer.editingPointPos = eventPlayer.getEyePosition()
    else:
        eventPlayer.editingPointPos = eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * eventPlayer.pointerDistance

    # replace value in points array
    eventPlayer.points[eventPlayer.editingPointIndex] = eventPlayer.editingPointPos
    destroyEffect(eventPlayer.pointsEffect[eventPlayer.editingPointIndex])

    createEffect(visibility, Effect.ORB, MAIN_POINT_COLOR, eventPlayer.editingPointPos, eventPlayer.pointRadius, EffectReeval.VISIBILITY)
    eventPlayer.pointsEffect[eventPlayer.editingPointIndex] = getLastCreatedEntity()

    eventPlayer.hasChanged = true
    if not eventPlayer.liveRenderDisabled:
        computeAllSegments()

    eventPlayer.pointerColor = POINTER_COLOR
    eventPlayer.editingCleanup = true

rule "Editing cleanup":
    @Event eachPlayer
    @Condition eventPlayer.isAddingPoints and eventPlayer.isEditingPoints and eventPlayer.editingCleanup
    @Condition not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.isEditingPoints = false
    eventPlayer.editingCleanup = false

rule "Inc duration":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) and eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.bezierDuration += 0.1

rule "Dec duration":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.bezierDuration -= 0.1

rule "toggle live render":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.JUMP)

    eventPlayer.liveRenderDisabled = not eventPlayer.liveRenderDisabled

    if eventPlayer.liveRenderDisabled:
        destroyHudText(eventPlayer.liveRenderText)
    else:
        hudHeader(eventPlayer, "Live render enabled", HudPosition.TOP, 0, Color.RED, HudReeval.NONE, SpecVisibility.NEVER)
        eventPlayer.liveRenderText = getLastCreatedText()
        computeAllSegments()

# uses the four points in eventplayer.bezier, and duration from eventplayer.bezierDuration
def doBezier():
    eventPlayer.X = eventPlayer.bezier[0]
    eventPlayer.Y = eventPlayer.bezier[1]
    eventPlayer.Z = eventPlayer.bezier[2]
    eventPlayer.T = 0

    chase(eventPlayer.X, eventPlayer.bezier[1], duration=eventPlayer.bezierDuration, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.Y, eventPlayer.bezier[2], duration=eventPlayer.bezierDuration, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.Z, eventPlayer.bezier[3], duration=eventPlayer.bezierDuration, ChaseReeval.DESTINATION_AND_DURATION)
    chase(eventPlayer.T, 1, duration=eventPlayer.bezierDuration, ChaseReeval.DESTINATION_AND_DURATION)

rule "Do curve preview":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.MELEE) and not eventPlayer.isHoldingButton(Button.ABILITY_1)

    # A = X + (Y - X) * T
    # B = Y + (Z - Y) * T
    # point = A + (B - A) * T
    # point = (X + (Y - X) * T) + ((Y + (Z - Y) * T) - (X + (Y - X) * T)) * T

    if eventPlayer.hasChanged:
        computeAllSegments()

    createEffect(visibility, Effect.ORB, PREVIEW_COLOR, updateEveryTick((eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T) + ((eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T) - (eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T)) * eventPlayer.T), 0.2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
        eventPlayer.previewEntity = getLastCreatedEntity()

    for eventPlayer.I in range(len(eventPlayer.points) - 1):
        eventPlayer.bezier = [eventPlayer.points[eventPlayer.I], eventPlayer.segments1[eventPlayer.I], eventPlayer.segments2[eventPlayer.I], eventPlayer.points[eventPlayer.I + 1]]
        doBezier()
        wait(eventPlayer.bezierDuration)

    destroyEffect(eventPlayer.previewEntity)


rule "Do curve camera":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ABILITY_2) and not eventPlayer.isHoldingButton(Button.ABILITY_1)

    if eventPlayer.hasChanged:
        computeAllSegments()

    visibility.remove(eventPlayer)
    textVisibility.remove(eventPlayer)

    eventPlayer.startCamera((eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T) + ((eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T) - (eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T)) * eventPlayer.T, eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T, 0)

    for eventPlayer.I in range(len(eventPlayer.points) - 1):
        eventPlayer.bezier = [eventPlayer.points[eventPlayer.I], eventPlayer.segments1[eventPlayer.I], eventPlayer.segments2[eventPlayer.I], eventPlayer.points[eventPlayer.I + 1]]
        doBezier()
        wait(eventPlayer.bezierDuration)

    eventPlayer.stopCamera()

    visibility.append(eventPlayer)
    textVisibility.append(eventPlayer)

rule "Do curve camera for everyone":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.ABILITY_2) and eventPlayer.isHoldingButton(Button.ABILITY_1)

    if eventPlayer.hasChanged:
        computeAllSegments()

    visibility = []
    textVisibilityHolder = textVisibility
    textVisibility = []

    getAllPlayers().startCamera((eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T) + ((eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T) - (eventPlayer.X + (eventPlayer.Y - eventPlayer.X) * eventPlayer.T)) * eventPlayer.T, eventPlayer.Y + (eventPlayer.Z - eventPlayer.Y) * eventPlayer.T, 0)

    for eventPlayer.I in range(len(eventPlayer.points) - 1):
        eventPlayer.bezier = [eventPlayer.points[eventPlayer.I], eventPlayer.segments1[eventPlayer.I], eventPlayer.segments2[eventPlayer.I], eventPlayer.points[eventPlayer.I + 1]]
        doBezier()
        wait(eventPlayer.bezierDuration)

    getAllPlayers().stopCamera()

    visibility = getAllPlayers()
    textVisibility = textVisibilityHolder

rule "Export elements":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) and eventPlayer.isHoldingButton(Button.MELEE) and eventPlayer.isHoldingButton(Button.ABILITY_1)

    computeAllSegments()

    printLog("----------------")
    for eventPlayer.I in range(len(eventPlayer.points) - 1):
        printLog("vect{0}".format(eventPlayer.points[eventPlayer.I]))
        printLog("vect{0}".format(eventPlayer.segments1[eventPlayer.I]))
        printLog("vect{0}".format(eventPlayer.segments2[eventPlayer.I]))
    printLog("vect{0}".format(eventPlayer.points[len(eventPlayer.points) -1 ]))

    smallMessage(eventPlayer, "Export complete")

rule "Restart":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) and eventPlayer.isHoldingButton(Button.RELOAD)

    restartMatch()