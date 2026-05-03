/* ============================================
 * ядро LowKey Mini OS
 * простое ядро для отображения логотипа
 * легко кастомизируется
 * ============================================ */

/* === настройки цветов (можно менять) === */
#define COLOR_BORDER     0x0b    /* голубой рамка */
#define COLOR_TITLE      0x0f    /* белый заголовок */
#define COLOR_SUBTITLE   0x0b    /* голубой подзаголовок */
#define COLOR_BG         0x00    /* чёрный фон */

/* === настройки позиции логотипа === */
#define LOGO_ROW         10      /* строка начала */
#define LOGO_COL         25      /* колонка начала */

/* === константы видеопамяти === */
#define VIDEO_MEMORY     0xb8000
#define SCREEN_WIDTH     80
#define SCREEN_HEIGHT    25

/* порт вывода для задержки */
#define PORT_80          0x80

/* структура символа в видеопамяти */
struct video_char {
    unsigned char ascii;
    unsigned char attr;
};

/* ============================================
 * основная точка входа ядра
 * ============================================ */
void kernel_main(void) {
    /* очистка экрана */
    clear_screen();
    
    /* рисование рамки */
    draw_border();
    
    /* вывод логотипа */
    draw_logo();
    
    /* бесконечный цикл (это заставка) */
    while (1) {
        /* можно добавить анимацию здесь */
        delay(100);
    }
}

/* ============================================
 * очистка всего экрана
 * ============================================ */
void clear_screen(void) {
    struct video_char *video = (struct video_char *)VIDEO_MEMORY;
    int i;
    
    for (i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        video[i].ascii = ' ';
        video[i].attr = (COLOR_BG << 4) | COLOR_BG;
    }
}

/* ============================================
 * рисование рамки вокруг экрана
 * ============================================ */
void draw_border(void) {
    struct video_char *video = (struct video_char *)VIDEO_MEMORY;
    int i;
    unsigned char attr = (COLOR_BG << 4) | COLOR_BORDER;
    
    /* верхняя и нижняя граница */
    for (i = 0; i < SCREEN_WIDTH; i++) {
        video[i].ascii = '-';                           /* верх */
        video[i].attr = attr;
        video[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH + i].ascii = '-';  /* низ */
        video[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH + i].attr = attr;
    }
    
    /* левая и правая граница */
    for (i = 0; i < SCREEN_HEIGHT; i++) {
        video[i * SCREEN_WIDTH].ascii = '|';          /* лево */
        video[i * SCREEN_WIDTH].attr = attr;
        video[i * SCREEN_WIDTH + SCREEN_WIDTH - 1].ascii = '|';     /* право */
        video[i * SCREEN_WIDTH + SCREEN_WIDTH - 1].attr = attr;
    }
    
    /* углы */
    video[0].ascii = '+';
    video[SCREEN_WIDTH - 1].ascii = '+';
    video[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH].ascii = '+';
    video[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH + SCREEN_WIDTH - 1].ascii = '+';
}

/* ============================================
 * вывод строки на экран
 * row - строка (0-24)
 * col - колонка (0-79)
 * str - текст
 * color - цвет символа
 * ============================================ */
void print_at(int row, int col, const char *str, unsigned char color) {
    struct video_char *video = (struct video_char *)VIDEO_MEMORY;
    unsigned char attr = (COLOR_BG << 4) | color;
    int i = 0;
    
    while (str[i] != '\0') {
        int pos = row * SCREEN_WIDTH + col + i;
        if (pos < SCREEN_WIDTH * SCREEN_HEIGHT) {
            video[pos].ascii = str[i];
            video[pos].attr = attr;
        }
        i++;
    }
}

/* ============================================
 * рисование логотипа LowKey Mini OS
 * легко менять текст и стили
 * ============================================ */
void draw_logo(void) {
    /* === строка 1: заголовок === */
    print_at(LOGO_ROW, LOGO_COL, " ██╗      ██████╗ ██╗  ██╗███████╗██╗   ██╗", COLOR_TITLE);
    
    /* === строка 2 === */
    print_at(LOGO_ROW + 1, LOGO_COL, " ██║     ██╔═══██╗██║ ██╔╝██╔════╝██║  ██║", COLOR_TITLE);
    
    /* === строка 3 === */
    print_at(LOGO_ROW + 2, LOGO_COL, " ██║     ██║   ██║█████╔╝ █████╗  ███████║", COLOR_TITLE);
    
    /* === строка 4 === */
    print_at(LOGO_ROW + 3, LOGO_COL, " ██║     ██║   ██║██╔═██╗ ██╔══╝  ██╔══██║", COLOR_TITLE);
    
    /* === строка 5 === */
    print_at(LOGO_ROW + 4, LOGO_COL, " ███████╗╚██████╔╝██║  ██╗███████╗██║  ██║", COLOR_TITLE);
    
    /* === строка 6: подзаголовок === */
    print_at(LOGO_ROW + 6, LOGO_COL + 8, "███╗   ███╗██╗███╗   ██╗██╗", COLOR_SUBTITLE);
    print_at(LOGO_ROW + 7, LOGO_COL + 8, "████╗ ████║██║████╗  ██║██║", COLOR_SUBTITLE);
    print_at(LOGO_ROW + 8, LOGO_COL + 8, "██╔████╔██║██║██╔██╗ ██║██║", COLOR_SUBTITLE);
    print_at(LOGO_ROW + 9, LOGO_COL + 8, "██║╚██╔╝██║██║██║╚██╗██║██║", COLOR_SUBTITLE);
    print_at(LOGO_ROW + 10, LOGO_COL + 8, "██║ ╚═╝ ██║██║██║ ╚████║██║", COLOR_SUBTITLE);
    
    /* === строка 12: os === */
    print_at(LOGO_ROW + 12, LOGO_COL + 15, " ██████╗ ███████╗", COLOR_TITLE);
    print_at(LOGO_ROW + 13, LOGO_COL + 15, "██╔═══██╗██╔════╝", COLOR_TITLE);
    print_at(LOGO_ROW + 14, LOGO_COL + 15, "██║   ██║███████╗", COLOR_TITLE);
    print_at(LOGO_ROW + 15, LOGO_COL + 15, "██║   ██║╚════██║", COLOR_TITLE);
    print_at(LOGO_ROW + 16, LOGO_COL + 15, "╚██████╔╝███████║", COLOR_TITLE);
    
    /* === нижняя подпись === */
    print_at(22, 28, "[ нажмите любую клавишу для выхода ]", 0x07);
}

/* ============================================
 * простая задержка
 * ============================================ */
void delay(int count) {
    volatile int i, j;
    for (i = 0; i < count; i++) {
        for (j = 0; j < 1000; j++) {
            __asm__ volatile ("nop");
        }
    }
}
