#include <stdint.h>

//  generalized shuffle SHFL / SHFLI
uint32_t rv32b_shfl(uint32_t rs1, uint32_t rs2);

//  generalized unshuffle UNSHFL / UNSHFLI
uint32_t rv32b_unshfl(uint32_t rs1, uint32_t rs2);

static inline uint32_t shuffle32_stage(uint32_t src, uint32_t ml,
									   uint32_t mr, int n)
{
	uint32_t x = src & ~(ml | mr);
	x |= ((src << n) & ml) | ((src >> n) & mr);
	return x;
}

uint32_t rv32b_shfl(uint32_t rs1, uint32_t rs2)
{
	uint32_t x = rs1;
	int shamt = rs2 & 15;

	if (shamt & 8)
		x = shuffle32_stage(x, 0x00FF0000, 0x0000FF00, 8);
	if (shamt & 4)
		x = shuffle32_stage(x, 0x0F000F00, 0x00F000F0, 4);
	if (shamt & 2)
		x = shuffle32_stage(x, 0x30303030, 0x0C0C0C0C, 2);
	if (shamt & 1)
		x = shuffle32_stage(x, 0x44444444, 0x22222222, 1);

	return x;
}

//  generalized unshuffle UNSHFL / UNSHFLI

uint32_t rv32b_unshfl(uint32_t rs1, uint32_t rs2)
{
	uint32_t x = rs1;
	int shamt = rs2 & 15;

	if (shamt & 1)
		x = shuffle32_stage(x, 0x44444444, 0x22222222, 1);
	if (shamt & 2)
		x = shuffle32_stage(x, 0x30303030, 0x0C0C0C0C, 2);
	if (shamt & 4)
		x = shuffle32_stage(x, 0x0F000F00, 0x00F000F0, 4);
	if (shamt & 8)
		x = shuffle32_stage(x, 0x00FF0000, 0x0000FF00, 8);

	return x;
}