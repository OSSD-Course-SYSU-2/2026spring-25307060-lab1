import struct
import zlib
import os

def create_png(width, height, pixels):
    """创建 PNG 图片"""
    def png_chunk(chunk_type, data):
        chunk_len = struct.pack('>I', len(data))
        chunk_crc = struct.pack('>I', zlib.crc32(chunk_type + data) & 0xffffffff)
        return chunk_len + chunk_type + data + chunk_crc
    
    # PNG 文件头
    signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = png_chunk(b'IHDR', ihdr_data)
    
    # IDAT chunk (图像数据)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # 过滤器类型
        for x in range(width):
            idx = (y * width + x) * 4
            raw_data += bytes(pixels[idx:idx+4])
    
    compressed_data = zlib.compress(raw_data, 9)
    idat = png_chunk(b'IDAT', compressed_data)
    
    # IEND chunk
    iend = png_chunk(b'IEND', b'')
    
    return signature + ihdr + idat + iend

def create_ledger_icon(size=216):
    """创建记账本图标"""
    pixels = []
    
    # 颜色定义
    white = (255, 255, 255, 255)
    transparent = (0, 0, 0, 0)
    book_cover = (102, 126, 234, 255)  # 紫蓝色封面
    book_spine = (76, 75, 162, 255)    # 深紫色书脊
    paper = (245, 245, 245, 255)       # 纸张颜色
    line_color = (200, 200, 200, 255)  # 线条颜色
    text_dark = (80, 80, 80, 255)      # 文字颜色
    accent_green = (76, 175, 80, 255)  # 绿色强调
    accent_red = (255, 87, 34, 255)    # 红色强调
    
    center_x = size // 2
    center_y = size // 2
    
    for y in range(size):
        for x in range(size):
            # 计算到中心的距离
            dx = x - center_x
            dy = y - center_y
            dist = (dx * dx + dy * dy) ** 0.5
            
            # 创建圆角矩形区域
            margin = size // 8
            book_left = margin
            book_right = size - margin
            book_top = margin + size // 16
            book_bottom = size - margin - size // 16
            
            # 圆角半径
            corner_radius = size // 10
            
            # 判断是否在圆角矩形内
            in_book = False
            if book_left + corner_radius <= x <= book_right - corner_radius:
                if book_top <= y <= book_bottom:
                    in_book = True
            elif book_left <= x < book_left + corner_radius:
                if book_top <= y <= book_bottom:
                    dx_corner = book_left + corner_radius - x
                    if y <= book_top + corner_radius:
                        dy_corner = book_top + corner_radius - y
                        if dx_corner * dx_corner + dy_corner * dy_corner <= corner_radius * corner_radius:
                            in_book = True
                    elif y >= book_bottom - corner_radius:
                        dy_corner = y - (book_bottom - corner_radius)
                        if dx_corner * dx_corner + dy_corner * dy_corner <= corner_radius * corner_radius:
                            in_book = True
            elif book_right - corner_radius < x <= book_right:
                if book_top <= y <= book_bottom:
                    dx_corner = x - (book_right - corner_radius)
                    if y <= book_top + corner_radius:
                        dy_corner = book_top + corner_radius - y
                        if dx_corner * dx_corner + dy_corner * dy_corner <= corner_radius * corner_radius:
                            in_book = True
                    elif y >= book_bottom - corner_radius:
                        dy_corner = y - (book_bottom - corner_radius)
                        if dx_corner * dx_corner + dy_corner * dy_corner <= corner_radius * corner_radius:
                            in_book = True
            elif book_left <= x <= book_right:
                if book_top <= y <= book_bottom:
                    in_book = True
            
            if not in_book:
                pixels.extend(transparent)
                continue
            
            # 书脊区域
            spine_width = size // 12
            if x <= book_left + spine_width:
                pixels.extend(book_spine)
                continue
            
            # 纸张区域
            paper_left = book_left + spine_width + size // 20
            paper_right = book_right - size // 20
            paper_top = book_top + size // 10
            paper_bottom = book_bottom - size // 10
            
            # 判断是否在纸张区域
            in_paper = (paper_left <= x <= paper_right and paper_top <= y <= paper_bottom)
            
            if in_paper:
                # 绘制纸张背景
                pixels.extend(paper)
                
                # 绘制横线
                line_spacing = size // 12
                line_y_start = paper_top + line_spacing
                for line_num in range(6):
                    line_y = line_y_start + line_num * line_spacing
                    if abs(y - line_y) <= 1:
                        # 绘制线条
                        pixels[-4:-1] = line_color[:3]
                        break
                
                # 绘制记账符号（简化的 ¥ 符号）
                symbol_center_x = (paper_left + paper_right) // 2
                symbol_center_y = paper_top + size // 8
                symbol_size = size // 10
                
                # ¥ 符号的横线
                if abs(y - symbol_center_y) <= 2:
                    if abs(x - symbol_center_x) <= symbol_size:
                        pixels[-4:-1] = text_dark[:3]
                if abs(y - (symbol_center_y + symbol_size // 2)) <= 2:
                    if abs(x - symbol_center_x) <= symbol_size:
                        pixels[-4:-1] = text_dark[:3]
                
                # ¥ 符号的竖线
                if abs(x - symbol_center_x) <= 2:
                    if symbol_center_y <= y <= symbol_center_y + symbol_size * 2:
                        pixels[-4:-1] = text_dark[:3]
                
                # ¥ 符号的斜线
                dx_sym = abs(x - symbol_center_x)
                dy_sym = y - symbol_center_y
                if 0 < dy_sym < symbol_size:
                    if abs(dx_sym - dy_sym // 2) <= 2:
                        pixels[-4:-1] = text_dark[:3]
                
                # 绘制收入/支出指示点
                dot_y = paper_bottom - size // 15
                dot_radius = size // 30
                
                # 绿色点（收入）
                green_dot_x = paper_left + size // 6
                dx_green = x - green_dot_x
                dy_green = y - dot_y
                if dx_green * dx_green + dy_green * dy_green <= dot_radius * dot_radius:
                    pixels[-4:-1] = accent_green[:3]
                
                # 红色点（支出）
                red_dot_x = paper_right - size // 6
                dx_red = x - red_dot_x
                dy_red = y - dot_y
                if dx_red * dx_red + dy_red * dy_red <= dot_radius * dot_radius:
                    pixels[-4:-1] = accent_red[:3]
                
            else:
                # 书籍封面
                pixels.extend(book_cover)
    
    return create_png(size, size, pixels)

# 生成图标
print("正在生成记账本图标...")
icon_data = create_ledger_icon(216)

# 保存图标文件
output_paths = [
    'entry/src/main/resources/base/media/foreground.png',
    'entry/src/main/resources/base/media/background.png',
    'AppScope/resources/base/media/foreground.png',
    'AppScope/resources/base/media/background.png',
    'entry/src/main/resources/base/media/startIcon.png'
]

for path in output_paths:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(icon_data)
    print(f"已生成: {path}")

print("图标生成完成！")
