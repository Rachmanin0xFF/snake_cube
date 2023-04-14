# snake_cube

![snake cube viz](screenshot.png?raw=true "snake")

A program to explore and solve the [snake cube puzzle](https://en.wikipedia.org/wiki/Snake_cube). This program uses an indexed representation of the chiral octahedral symmetry group to quickly embed the snake in 3D space.

Most programs designed to evaluate this puzzle take a complete cube, then attempt to find hamiltonian paths through it. I wanted something that did the opposite: I give it a snake, and it tells me what shapes I can make using that snake.

The solver's performance could seriously benefit from a divide-and-conquer method. I may implement this at some point.

Written in [Processing](https://processing.org/), uses [PeasyCam](https://mrfeinberg.com/peasycam/) for camera controls.
