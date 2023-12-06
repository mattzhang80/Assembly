#include "bigint.h"
#include "bigintprivate.h"
#include <string.h>
#include <assert.h>

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

static long BigInt_larger(long lLength1, long lLength2)
{
   long lLarger;

   if (lLength1 <= lLength2) goto larger_if1;

   lLarger = lLength1;
   goto larger_end;
   
larger_if1:
   lLarger = lLength2;

larger_end:
   return lLarger;
}

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

   lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);

   if (oSum->lLength <= lSumLength) goto after_memset;
   memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));

after_memset:
   ulCarry = 0;
   lIndex = 0;

loop_start:
   if (lIndex >= lSumLength) goto loop_end;

   ulSum = ulCarry;
   ulCarry = 0;

   ulSum += oAddend1->aulDigits[lIndex];
   if (ulSum >= oAddend1->aulDigits[lIndex]) goto add_if1;
   ulCarry = 1;

add_if1:
   ulSum += oAddend2->aulDigits[lIndex];
   if (ulSum >= oAddend2->aulDigits[lIndex]) goto add_if2;
   ulCarry = 1;

add_if2:
   oSum->aulDigits[lIndex] = ulSum;
   lIndex++;
   goto loop_start;

loop_end:
   if (ulCarry != 1) goto set_sumlength;
   if (lSumLength != MAX_DIGITS) return FALSE;
   oSum->aulDigits[lSumLength] = 1;
   lSumLength++;

set_sumlength:
   oSum->lLength = lSumLength;
   return TRUE;
}
