# simple-powershell-raytracer
Super SUPER simple - literally useless - ascii raytracer made in powershell - inspired by @Dr.Vlasanek @ yt

###

### What it looks like!
![cool](https://github.com/jh1sc/simple-powershell-raytracer/blob/main/Screenshot%202025-02-22%20155246.png)



1. Ray Definition:
   - A ray is defined by an origin point and a direction vector. It represents the path of light as it travels through the scene.

2. Sphere Intersection:
   - For each ray, the algorithm checks if it intersects with any spheres in the scene.
   - This involves solving the quadratic equation derived from the ray's equation and the sphere's equation:
     ```
     delta = b^2 - 4ac
     ```
   - If the discriminant `delta` is non-negative, the ray intersects the sphere.

3. Finding Intersection Points:
   - If an intersection occurs, the algorithm calculates the points `t1` and `t1` where the ray intersects the sphere using:
     ```
     t = (-b +/- √delta) / 2a
     ```
   - The smaller positive `t` value represents the closest intersection point.

4. Lighting Calculations:
   - After finding the closest sphere, the algorithm calculates the normal vector at the intersection point and the direction to the light source.
   - It computes the diffuse reflection using the dot product between the normal vector and the light direction:
     ```
     Diffuse = max(0, normal * light_dir)
     ```

5. Specular Reflection:
   - The algorithm also calculates the specular reflection, which gives the shiny highlight effect, using the view direction and the reflected light direction:
     ```
     Specular = (max(0, view_dir * reflect_dir))^32
     ```

6. Color Calculation:
   - The final color of the pixel is computed by combining the diffuse and specular components with the sphere's color:
     ```
     color = sphere.color * (Diffuse + 0.3) + white * (Specular / 2)
     ```
   - The resulting color is clamped to ensure RGB values remain within the range `[0, 1]`.

7. Rendering the Scene:
   - This process is repeated for each pixel in the output image, generating a complete rendered image of the scene.
