# On wayland run using x11
# env PYOPENGL_PLATFORM=x11 python3 flappy.py

import random
import time
from OpenGL.GL import *
from OpenGL.GLUT import *
from OpenGL.GLU import *


WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600
BIRD_SIZE = 30
PIPE_WIDTH = 80
PIPE_GAP = 200
PIPE_SPEED = 3
GRAVITY = 0.5
JUMP_STRENGTH = 10
PIPE_SPAWN_INTERVAL = 1.5


# Game state
bird_x = 100  # const
bird_y = WINDOW_HEIGHT // 2
bird_velocity = 0
score = 0
game_over = False
pipes = []  # List of [x, gap_y] for each pipe
last_pipe_time = 0


class Pipe:
    def __init__(self, x, gap_y):
        self.x = x
        self.gap_y = gap_y
        self.passed = False  # Track if bird has passed this pipe

    def update(self):
        self.x -= PIPE_SPEED

    def is_offscreen(self):
        return self.x + PIPE_WIDTH < 0

    def check_pass(self, bird_x):
        # Return True if bird just passed this pipe
        if not self.passed and self.x + PIPE_WIDTH < bird_x:
            self.passed = True
            return True
        return False


def draw_rectangle(x, y, width, height, color):
    glColor3f(*color)
    glBegin(GL_QUADS)
    glVertex2f(x, y)
    glVertex2f(x + width, y)
    glVertex2f(x + width, y + height)
    glVertex2f(x, y + height)
    glEnd()


# For the blob we're calling bird:
# It stays at x=100 (always 100 steps from the left edge)
# Its y-position changes when it jumps or falls
# The bird is a 30×30 square, so when we say "bird_y", we're talking about its middle point
def draw_bird():
    # Draw bird as a yellow square
    draw_rectangle(
        bird_x, bird_y - BIRD_SIZE // 2, BIRD_SIZE, BIRD_SIZE, (1.0, 1.0, 0.0)
    )


# For the bottom pipe:
# The bottom pipe starts at y=0 (the bottom of the screen)
# Its height needs to extend up to the bottom edge of the gap
# This bottom edge is at pipe.gap_y - PIPE_GAP//2
# So the bottom pipe has coordinates: (pipe.x, 0) with height pipe.gap_y - PIPE_GAP//2
#
# For the top pipe:
# The top pipe starts at the top edge of the gap
# This top edge is at pipe.gap_y + PIPE_GAP//2
# It extends all the way to the top of the screen (WINDOW_HEIGHT)
# So its height is WINDOW_HEIGHT - (pipe.gap_y + PIPE_GAP//2)
# The top pipe has coordinates: (pipe.x, pipe.gap_y + PIPE_GAP//2) with that height
#
#        |          |
#        |  TOP     |  ← Extends from gap to top of screen
#        |  PIPE    |
#        |          |
#        ------------  ← pipe.gap_y + PIPE_GAP//2
#
#        PIPE_GAP space for bird to fly through
#
#        ------------  ← pipe.gap_y - PIPE_GAP//2
#        |          |
#        | BOTTOM   |  ← Extends from bottom of screen to gap
#        |  PIPE    |
#        |          |
def draw_pipe(pipe):
    # Draw top pipe
    draw_rectangle(
        pipe.x,
        pipe.gap_y + PIPE_GAP // 2,
        PIPE_WIDTH,
        WINDOW_HEIGHT - (pipe.gap_y + PIPE_GAP // 2),
        (0.0, 0.8, 0.0),
    )

    # Draw bottom pipe
    draw_rectangle(
        pipe.x,
        0,
        PIPE_WIDTH,
        pipe.gap_y - PIPE_GAP // 2,
        (0.0, 0.8, 0.0),
    )


def draw_score():
    glColor3f(0.0, 0.0, 0.0)
    glRasterPos2f(10, WINDOW_HEIGHT - 30)
    for c in f"Score: {score}":
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, ord(c))  # type: ignore


def draw_info():
    glColor3f(1.0, 1.0, 1.0)

    glRasterPos2f(10, WINDOW_HEIGHT - 50)
    for c in "SPACE to Jump":
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, ord(c))  # type: ignore

    glRasterPos2f(10, WINDOW_HEIGHT - 70)
    for c in "R to Restart":
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, ord(c))  # type: ignore

    glRasterPos2f(10, WINDOW_HEIGHT - 90)
    for c in "Q or ESC to quit":
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, ord(c))  # type: ignore

    glColor3f(0.74, 0.14, 0.29)  # (191, 37, 76) #bf254c
    glRasterPos2f(WINDOW_WIDTH - 100, WINDOW_HEIGHT - 30)
    for c in "© KHALED":
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, ord(c))  # type: ignore


def draw_game_over():
    glColor3f(1.0, 0.0, 0.0)
    glRasterPos2f(WINDOW_WIDTH // 2 - 150, WINDOW_HEIGHT // 2)
    for c in "You Suck! Press R to suck again":
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, ord(c))  # type: ignore


def restart():
    global bird_velocity, bird_y, pipes, score, game_over, last_pipe_time
    bird_y = WINDOW_HEIGHT // 2
    bird_velocity = 0
    pipes = []
    score = 0
    game_over = False
    last_pipe_time = 0


# Check for collisions
def committed_die():
    # Check if bird hit the ground or ceiling
    if bird_y - BIRD_SIZE // 2 <= 0 or bird_y + BIRD_SIZE // 2 >= WINDOW_HEIGHT:
        return True

    # Check if bird hit any pipe
    bird_left = bird_x
    bird_right = bird_x + BIRD_SIZE
    bird_top = bird_y + BIRD_SIZE // 2
    bird_bottom = bird_y - BIRD_SIZE // 2

    for pipe in pipes:
        # Only check if the bird is horizontally aligned with the pipe
        if pipe.x > bird_right or pipe.x + PIPE_WIDTH < bird_left:
            continue

        # Check collision with top pipe
        if bird_top > pipe.gap_y + PIPE_GAP // 2:
            return True

        # Check collision with bottom pipe
        if bird_bottom < pipe.gap_y - PIPE_GAP // 2:
            return True

    return False


def display():
    glClear(GL_COLOR_BUFFER_BIT)

    draw_bird()
    for pipe in pipes:
        draw_pipe(pipe)

    draw_score()
    draw_info()

    global game_over
    if game_over:
        draw_game_over()

    glutSwapBuffers()  # Flip Display (GLUT_DOUBLE Buffer)


# Physicss go brrrrrrr
def update(value):
    global bird_x, bird_y, bird_velocity, pipes, last_pipe_time, score, game_over

    if not game_over:
        game_over = committed_die()
        current_time = time.time()

        # Update bird position and velocity
        bird_velocity -= GRAVITY
        bird_y += bird_velocity

        # Spawn new pipes
        if current_time - last_pipe_time > PIPE_SPAWN_INTERVAL:
            gap_y = random.randint(
                PIPE_GAP // 2 + 50, WINDOW_HEIGHT - PIPE_GAP // 2 - 50
            )
            pipes.append(Pipe(WINDOW_WIDTH, gap_y))
            last_pipe_time = current_time

        # Update pipes and score
        for pipe in pipes:
            pipe.update()

            # Check if pipe has just passed the bird's position
            if pipe.check_pass(bird_x):
                score += 1

            if pipe.is_offscreen():
                pipes.remove(pipe)

    glutPostRedisplay()  # Redraw display()
    glutTimerFunc(16, update, 0)  # ~60 fps


def keyboard(key, x, y):
    global bird_velocity

    match key:
        case b" " if not game_over:  # Jump
            bird_velocity = JUMP_STRENGTH

        case b"q" | b"Q" | b"\x1b":  # Quit
            glutLeaveMainLoop()

        case b"r" | b"R":
            restart()


def main():
    glutInit(sys.argv)
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB)  # Smoother than GLUT_SINGLE??
    glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    glutCreateWindow(b"Scuffed Bird")

    glClearColor(0.53, 0.81, 0.92, 1.0)  # Sky blue background
    glMatrixMode(GL_PROJECTION)  # Top View Camera
    gluOrtho2D(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT)  # 2D View

    glutDisplayFunc(display)
    glutKeyboardFunc(keyboard)
    update(None)
    glutMainLoop()


if __name__ == "__main__":
    main()
