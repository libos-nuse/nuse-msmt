#include <stdio.h>
#include <time.h>

int
main()
{
	struct timespec ts = {5, 1000};

	fprintf(stderr, "I beheld the wretch — the miserable monster whom I had created.\n");
	nanosleep(&ts, NULL);

	return 0;
}
