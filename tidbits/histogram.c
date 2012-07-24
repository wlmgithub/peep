//
//  http://stackoverflow.com/questions/3989790/print-a-histogram-based-on-word-lengths-c
//
//  gcc -ansi -pedantic-errors -Wall -o histogram histogram.c
//  ./histogram < words.txt # some words in text file
//
//
#include <stdio.h>
#include <stdlib.h>

#define MAXWORLDLENGTH 10

#define IN  1
#define OUT 0


void readWordCounts(int wt[], int maxWordLength)
{
    int c, state, wl, i;

    wl = 0;
    for (i = 0; i != maxWordLength + 1; ++i)
        wt[i] = 0;
    state = OUT;

    while ((c = getchar()) != EOF)
        if (c != ' ' && c != '\t' && c != '\n')
        {
                    state = IN;
                    ++wl;
                }
        else if (state == IN)
        {
                    state = OUT;
                    if (wl > maxWordLength)
                        ++wt[maxWordLength];
                    else
                        ++wt[wl - 1];
                    wl = 0;
                }
}



void printVerticalHistogram(int wt[], int maxWordLength)
{
    int maxValue;
    int i, j;

    /* Find maximum value in data set */
    maxValue = 0;
    for (i = 0; i != maxWordLength + 1; ++i)
        if (wt[i] > maxValue)
            maxValue = wt[i];

    /* Display histogram body */
    for (i = maxValue; i != 0; --i)
    {
            for (j = 0; j != maxWordLength + 1; ++j)
            {
                        if (wt[j] >= i)
                            printf(" X ");
                        else
                            printf("   ");
                        putchar(' ');
                    }
            putchar('\n');
        }

    /* Display separator */
    for (i = 0; i != (maxWordLength + 1)*4 - 1; ++i)
        putchar('-');
    putchar('\n');

    /* Display header */
    for (i = 0; i != maxWordLength + 1; ++i)
        if (i != maxWordLength)
            printf("%03d ", i + 1);
        else
            printf(">%02d", maxWordLength);
    putchar('\n');
}

int main(void)
{
    int wt[MAXWORLDLENGTH + 1];

    readWordCounts(wt, MAXWORLDLENGTH);
    printVerticalHistogram(wt, MAXWORLDLENGTH);

    return 0;
}


