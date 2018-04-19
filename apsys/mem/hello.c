#include <stdio.h>
#include <time.h>

int
main()
{
	struct timespec ts = {10, 1000};

	nanosleep(&ts, NULL);
	fprintf(stderr, "I beheld the wretch — the miserable monster whom I had created.\n");
	nanosleep(&ts, NULL);

	return 0;
}
