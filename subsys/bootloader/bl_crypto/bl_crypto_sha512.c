/*
 * Copyright (c) 2024 Nordic Semiconductor ASA
 *
 * SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
 */

#include <zephyr/types.h>
#include <bl_crypto.h>
#include <bl_storage.h>
#include <fw_info.h>
#include <psa/crypto.h>

int bl_crypto_init(void)
{
}

int bl_sha512_init(bl_sha512_ctx_t * const ctx)
{
	*ctx = psa_hash_operation_init();
	return (int)psa_hash_setup(ctx, PSA_ALG_SHA_512);;
}

int bl_sha512_update(bl_sha512_ctx_t *ctx, const uint8_t *data, uint32_t data_len)
{
	return (int)psa_hash_update(ctx, data, data_len);
}

int bl_sha512_finalize(bl_sha512_ctx_t *ctx, uint8_t *output)
{
	size_t hash_length = 0;
	/* Assumes the output buffer is at least the expected size of the hash */
	return (int)psa_hash_finish(ctx, output, PSA_HASH_LENGTH(PSA_ALG_SHA_512), &hash_length);
}

int get_hash(uint8_t *hash, const uint8_t *data, uint32_t data_len, bool external)
{
}

#if 0
#ifndef CONFIG_BL_ROT_VERIFY_EXT_API_REQUIRED
#include <assert.h>
#include <ocrypto_constant_time.h>
#include "bl_crypto_internal.h"

static int verify_truncated_hash(const uint8_t *data, uint32_t data_len,
		const uint8_t *expected, uint32_t hash_len, bool external)
{
	uint8_t hash[CONFIG_SB_HASH_LEN];

	int retval = get_hash(hash, data, data_len, external);
	if (retval != 0) {
		return retval;
	}
	if (!ocrypto_constant_time_equal(expected, hash, hash_len)) {
		return -EHASHINV;
	}
	return 0;
}

static int verify_signature(const uint8_t *data, uint32_t data_len,
		const uint8_t *signature, const uint8_t *public_key, bool external)
{
	uint8_t hash1[CONFIG_SB_HASH_LEN];
	uint8_t hash2[CONFIG_SB_HASH_LEN];

	int retval = get_hash(hash1, data, data_len, external);
	if (retval != 0) {
		return retval;
	}

	retval = get_hash(hash2, hash1, CONFIG_SB_HASH_LEN, external);
	if (retval != 0) {
		return retval;
	}

	return bl_secp256r1_validate(hash2, CONFIG_SB_HASH_LEN, public_key, signature);
}

/* Base implementation, with 'external' parameter. */
static int root_of_trust_verify(
		const uint8_t *public_key, const uint8_t *public_key_hash,
		const uint8_t *signature, const uint8_t *firmware,
		const uint32_t firmware_len, bool external)
{
	__ASSERT(public_key && public_key_hash && signature && firmware,
			"A parameter was NULL.");
	int retval = verify_truncated_hash(public_key, CONFIG_SB_PUBLIC_KEY_LEN,
			public_key_hash, SB_PUBLIC_KEY_HASH_LEN, external);

	if (retval != 0) {
		return retval;
	}

	return verify_signature(firmware, firmware_len, signature, public_key,
			external);
}
#endif

int root_of_trust_verify(
		const uint8_t *public_key, const uint8_t *public_key_hash,
		const uint8_t *signature, const uint8_t *firmware,
		const uint32_t firmware_len, bool external);


/* For use by the bootloader. */
int bl_root_of_trust_verify(const uint8_t *public_key, const uint8_t *public_key_hash,
			 const uint8_t *signature, const uint8_t *firmware,
			 const uint32_t firmware_len)
{
	return root_of_trust_verify(public_key, public_key_hash, signature,
					firmware, firmware_len, false);
}


/* For use through EXT_API. */
int bl_root_of_trust_verify_external(
			const uint8_t *public_key, const uint8_t *public_key_hash,
			const uint8_t *signature, const uint8_t *firmware,
			const uint32_t firmware_len)
{
	return root_of_trust_verify(public_key, public_key_hash, signature,
					firmware, firmware_len, true);
}
#endif

#ifndef CONFIG_BL_SHA512_EXT_API_REQUIRED
int bl_sha512_verify(const uint8_t *data, uint32_t data_len, const uint8_t *expected)
{
	return verify_truncated_hash(data, data_len, expected, CONFIG_SB_HASH_LEN, true);
}
#endif

#ifdef CONFIG_BL_ROT_VERIFY_EXT_API_ENABLED
EXT_API(BL_ROT_VERIFY, struct bl_rot_verify_ext_api, bl_rot_verify_ext_api) = {
		.bl_root_of_trust_verify = bl_root_of_trust_verify_external,
	}
};
#endif

#ifdef CONFIG_BL_SHA512_EXT_API_ENABLED
EXT_API(BL_SHA512, struct bl_sha512_ext_api, bl_sha512_ext_api) = {
		.bl_sha512_init = bl_sha512_init,
		.bl_sha512_update = bl_sha512_update,
		.bl_sha512_finalize = bl_sha512_finalize,
//		.bl_sha512_verify = bl_sha512_verify,
		.bl_sha512_ctx_size = SHA512_CTX_SIZE,
	}
};
#endif

#ifdef CONFIG_BL_ED25519_EXT_API_ENABLED
EXT_API(BL_ED25519, struct bl_ed25519_ext_api, bl_ed25519_ext_api) = {
		.bl_ed25519_validate = bl_ed25519_validate,
	}
};
#endif
