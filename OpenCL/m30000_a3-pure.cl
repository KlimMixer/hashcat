/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#define NEW_SIMD_CODE

#ifdef KERNEL_STATIC
#include "inc_vendor.h"
#include "inc_types.h"
#include "inc_platform.cl"
#include "inc_common.cl"
#include "inc_simd.cl"
#include "inc_hash_md5.cl"
#endif

KERNEL_FQ void m30000_mxx (KERN_ATTR_VECTOR ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * base
   */

  const u32 pw_len = pws[gid].pw_len;

  u32x w[64] = { 0 };

  for (u32 i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  /**
   * loop
   */

  u32x w0l = w[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    w[0] = w0;

    md5_ctx_vector_t ctx;

    md5_init_vector (&ctx);

    md5_update_vector (&ctx, w, pw_len);

    md5_final_vector (&ctx);

    u8 buff[16];
    buff[0]  = ((u8) (ctx.h[DGST_R0] >>  0));
    buff[1]  = ((u8) (ctx.h[DGST_R0] >>  8));
    buff[2]  = ((u8) (ctx.h[DGST_R0] >> 16));
    buff[3]  = ((u8) (ctx.h[DGST_R0] >> 24));
    buff[4]  = ((u8) (ctx.h[DGST_R1] >>  0));
    buff[5]  = ((u8) (ctx.h[DGST_R1] >>  8));
    buff[6]  = ((u8) (ctx.h[DGST_R1] >> 16));
    buff[7]  = ((u8) (ctx.h[DGST_R1] >> 24));
    buff[8]  = ((u8) (ctx.h[DGST_R2] >>  0));
    buff[9]  = ((u8) (ctx.h[DGST_R2] >>  8));
    buff[10] = ((u8) (ctx.h[DGST_R2] >> 16));
    buff[11] = ((u8) (ctx.h[DGST_R2] >> 24));
    buff[12] = ((u8) (ctx.h[DGST_R3] >>  0));
    buff[13] = ((u8) (ctx.h[DGST_R3] >>  8));
    buff[14] = ((u8) (ctx.h[DGST_R3] >> 16));
    buff[15] = ((u8) (ctx.h[DGST_R3] >> 24));

    u8 temp_result[9];
    temp_result[8] = 0;

    for(int i = 0; i<8; i++)
    {
      u8 tmp = (buff[2*i] + buff[2*i+1]) % 0x3e;
      if(tmp > 9)
      {
        if(tmp > 35)
        {
          tmp += 61;
        }
        else
        {
          tmp += 55;
        }
      }
      else
      {
        tmp += 0x30;
      }
      temp_result[i] = tmp;
    }

    u8 temp = 0;

    temp = temp_result[2];
    temp_result[2] = temp_result[6];
    temp_result[6] = temp;

    temp = temp_result[3];
    temp_result[3] = temp_result[7];
    temp_result[7] = temp;    

    u32x result[4];

    result[DGST_R0] = 0;
    result[DGST_R1] = 0;
    result[DGST_R2] = 0;
    result[DGST_R3] = 0;

    result[DGST_R0] |= ((u32) (temp_result[0] <<  0));
    result[DGST_R0] |= ((u32) (temp_result[1] <<  8));
    result[DGST_R0] |= ((u32) (temp_result[2] << 16));
    result[DGST_R0] |= ((u32) (temp_result[3] << 24));
    result[DGST_R1] |= ((u32) (temp_result[4] <<  0));
    result[DGST_R1] |= ((u32) (temp_result[5] <<  8));
    result[DGST_R1] |= ((u32) (temp_result[6] << 16));
    result[DGST_R1] |= ((u32) (temp_result[7] << 24));

    const u32x r0 = result[DGST_R0];
    const u32x r1 = result[DGST_R1];
    const u32x r2 = result[DGST_R2];
    const u32x r3 = result[DGST_R3];

    COMPARE_M_SIMD (r0, r1, r2, r3);
  }
}

KERNEL_FQ void m30000_sxx (KERN_ATTR_VECTOR ())
{
  /**
   * modifier
   */

  const u64 lid = get_local_id (0);
  const u64 gid = get_global_id (0);

  if (gid >= gid_max) return;

  /**
   * digest
   */

  const u16 search[4] =
  {
    digests_buf[digests_offset].digest_buf[DGST_R0],
    digests_buf[digests_offset].digest_buf[DGST_R1],
    digests_buf[digests_offset].digest_buf[DGST_R2],
    digests_buf[digests_offset].digest_buf[DGST_R3]
  };

  /**
   * base
   */

  const u32 pw_len = pws[gid].pw_len;

  u32x w[64] = { 0 };

  for (u32 i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  /**
   * loop
   */

  u32x w0l = w[0];

  for (u32 il_pos = 0; il_pos < il_cnt; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    w[0] = w0;

    md5_ctx_vector_t ctx;

    md5_init_vector (&ctx);

    md5_update_vector (&ctx, w, pw_len);

    md5_final_vector (&ctx);

    u8 buff[16];
    buff[0]  = ((u8) (ctx.h[DGST_R0] >>  0));
    buff[1]  = ((u8) (ctx.h[DGST_R0] >>  8));
    buff[2]  = ((u8) (ctx.h[DGST_R0] >> 16));
    buff[3]  = ((u8) (ctx.h[DGST_R0] >> 24));
    buff[4]  = ((u8) (ctx.h[DGST_R1] >>  0));
    buff[5]  = ((u8) (ctx.h[DGST_R1] >>  8));
    buff[6]  = ((u8) (ctx.h[DGST_R1] >> 16));
    buff[7]  = ((u8) (ctx.h[DGST_R1] >> 24));
    buff[8]  = ((u8) (ctx.h[DGST_R2] >>  0));
    buff[9]  = ((u8) (ctx.h[DGST_R2] >>  8));
    buff[10] = ((u8) (ctx.h[DGST_R2] >> 16));
    buff[11] = ((u8) (ctx.h[DGST_R2] >> 24));
    buff[12] = ((u8) (ctx.h[DGST_R3] >>  0));
    buff[13] = ((u8) (ctx.h[DGST_R3] >>  8));
    buff[14] = ((u8) (ctx.h[DGST_R3] >> 16));
    buff[15] = ((u8) (ctx.h[DGST_R3] >> 24));

    u8 temp_result[9];
    temp_result[8] = 0;

    for(int i = 0; i<8; i++)
    {
      u8 tmp = (buff[2*i] + buff[2*i+1]) % 0x3e;
      if(tmp > 9)
      {
        if(tmp > 35)
        {
          tmp += 61;
        }
        else
        {
          tmp += 55;
        }
      }
      else
      {
        tmp += 0x30;
      }
      temp_result[i] = tmp;
    }

    u8 temp = 0;

    temp = temp_result[2];
    temp_result[2] = temp_result[6];
    temp_result[6] = temp;

    temp = temp_result[3];
    temp_result[3] = temp_result[7];
    temp_result[7] = temp;    

    u32x result[4];

    result[DGST_R0] = 0;
    result[DGST_R1] = 0;
    result[DGST_R2] = 0;
    result[DGST_R3] = 0;

    result[DGST_R0] |= ((u32) (temp_result[0] <<  0));
    result[DGST_R0] |= ((u32) (temp_result[1] <<  8));
    result[DGST_R0] |= ((u32) (temp_result[2] << 16));
    result[DGST_R0] |= ((u32) (temp_result[3] << 24));
    result[DGST_R1] |= ((u32) (temp_result[4] <<  0));
    result[DGST_R1] |= ((u32) (temp_result[5] <<  8));
    result[DGST_R1] |= ((u32) (temp_result[6] << 16));
    result[DGST_R1] |= ((u32) (temp_result[7] << 24));

    const u32x r0 = result[DGST_R0];
    const u32x r1 = result[DGST_R1];
    const u32x r2 = result[DGST_R2];
    const u32x r3 = result[DGST_R3];

    COMPARE_S_SIMD (r0, r1, r2, r3);
  }
}

