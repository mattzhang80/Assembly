#include "bigint.h"
#include "bigintprivate.h"
#include <string.h>
#include <assert.h>

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

int BigInt_add(BigInt_T oAddend1, BigInt_T oAddend2, BigInt_T oSum)
{
   unsigned long ulCarry;
   unsigned long ulSum;
   long lIndex;
   long lSumLength;

   assert(oAddend1 != NULL);
   assert(oAddend2 != NULL);
   assert(oSum != NULL);
   assert(oSum != oAddend1);
   assert(oSum != oAddend2);

   /* Determine the larger length. */
   if (oAddend1->lLength > oAddend2->lLength) lSumLength = oAddend1->lLength;
   else lSumLength = oAddend2->lLength;

   /* Clear oSum's array if necessary. */
   if (oSum->lLength > lSumLength)
      memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

   /* Perform the addition. */
   ulCarry = 0;
   lIndex = 0;

   loop1:
   if (!(lIndex < lSumLength)) goto endloop1;
   ulSum = ulCarry + oAddend1->aulDigits[lIndex] + oAddend2->aulDigits[lIndex];
   ulCarry = (ulSum < oAddend1->aulDigits[lIndex] || ulSum < oAddend2->aulDigits[lIndex]) ? 1 : 0;
   oSum->aulDigits[lIndex] = ulSum;
   lIndex++;
   goto loop1;

   endloop1:
   /* Check for a carry out of the last "column" of the addition. */
   if (ulCarry != 1) goto endif1;
   if (lSumLength == MAX_DIGITS)
      return FALSE;
   oSum->aulDigits[lSumLength] = 1;
   lSumLength++;

   endif1:
   /* Set the length of the sum. */
   oSum->lLength = lSumLength;

   return TRUE;
}
