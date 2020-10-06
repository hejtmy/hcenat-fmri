import os
import cv2
import re
imsize = (1434,1434)
# top, right, bottom, left
margins = (82,1406,1381,60)
real_image_size = (1300, 1346)
center = (650, 673)

ptr = r"_([0-9]*)\.png"

dir_path = "data/gift-images"
image_files = os.listdir(dir_path)

for image_file in image_files:
    pth = os.path.join(dir_path, image_file)
    img = cv2.imread(pth)
    image_num = int(re.search(ptr, image_file).group(1))
    i_start_component = 1 + ((image_num - 1) * 4)
    split_image(img, margins, center, i_start_component)
    
def split_image(img, margins, center, count_start):
    for r in range(0,2):
        for c in range(0,2):
            image = img[(margins[0]+center[0]*r):margins[0] + center[0]*(r+1), 
                        margins[3]+center[1]*c:margins[3]+center[1]*(c+1), :]
            i_comp = r*2 + c + count_start
            cv2.imwrite(f"component_{i_comp}.png", image)
