/* QUERY PRESENTACION INTERVET: TIEMPOS DE OPERACIÓN + ESTADO DE CUENTA (CUENTAS DE GASTOS) */
/* Base: intervet_tableau.sql  +  campos de intervet_cuentas.sql */
/* Llave de union: Referencia (principal) + Cuenta de gastos */
/*   SABANA.Referencia          <-> SIR_VT_CCEstadoDeCuenta.Referencia */
/*   SABANA.[Cuenta de gastos]  <-> SIR_VT_CCEstadoDeCuenta.CuentaDeGasto */
/* Una referencia puede tener mas de una cuenta de gastos: cada cuenta se une */
/* solo con las partidas de esa referencia que la tienen asignada. */
/* Ultima modificacion: 23/09/2026 */
/* TABLEAU */


SELECT

 Sucursal AS Sucursal,
  CASE
   WHEN Sucursal = 'CIUDAD DE MÉXICO' THEN 'AÉREO AICM'
   WHEN Sucursal = 'AIFA ESTADO DE MEXICO' THEN 'AÉREO AIFA'
   WHEN Sucursal = 'VERACRUZ' THEN 'MARÍTIMO VERACRUZ'
   WHEN CHARINDEX('LT', Referencia) > 0 THEN 'LAREDO'
   when CHARINDEX('NLS', Referencia) > 0 THEN 'NUEVO LAREDO'
   WHEN CHARINDEX('MNS', Referencia) > 0 THEN 'MANZANILLO'
   WHEN CHARINDEX('MNA', Referencia) > 0 THEN 'MANZANILLO'
   ELSE 'CORRESPONSALIAS'
  END AS [Tipo Sucursal],
 Referencia,
 [Aduana/Sección Despacho],
 ---------------------------------------------------------------------------------------------------
 CAST([dFechaPago] AS DATE) AS 'Fecha de pago',
CASE
    WHEN Sucursal = 'CORRESPONSALIAS' THEN MONTH([Corresponsalias Fecha de Pago])
    ELSE MONTH([dFechaPago])
END AS "MES",


 [Fecha Entrada/Presentación],
 [recti a cargo de],
 CONCAT(SUBSTRING(TRIM([CuentaG_Folio_Num_Factura]),1,1),TRIM([CuentaG_FolioFactura])) AS 'Cuenta de gastos',
 /*---------------Función de Fecha de pago---------------*/

CONVERT(VARCHAR(10),
 CASE
  WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
  WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
  ELSE [dFechaPago]
  END, 103) AS [Fecha de Pago funcion],


  /*---------------Entrada de pago-----------------*/

    (
        DATEDIFF(DAY,
            TRY_CAST([Fecha Entrada/Presentación] AS DATE),
            TRY_CAST(
                CASE
                    WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                    WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                    ELSE [dFechaPago]
                END AS DATE
            )
        )
        - (DATEDIFF(WEEK,
            TRY_CAST([Fecha Entrada/Presentación] AS DATE),
            TRY_CAST(
                CASE
                    WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                    WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                    ELSE [dFechaPago]
                END AS DATE
            )
        ) * 2)
        - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
        - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(
                CASE
                    WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                    WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                    ELSE [dFechaPago]
                END AS DATE
            )) = 'Sábado' THEN 1 ELSE 0 END)
    ) AS [Entrada de pago],

/*------------------------------ Etiqueta Entrada a Pago -----------------------------*/

    -- Etiqueta Entrada a Pago (días hábiles)
    CASE
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 0 AND 1 THEN '1 día o menos'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 2 AND 3 THEN '2 a 3 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 4 AND 5 THEN '4 a 5 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 6 AND 10 THEN '6 a 10 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(
                    CASE
                        WHEN Sucursal = 'CORRESPONSALIAS' THEN [Corresponsalias Fecha de Pago]
                        WHEN Sucursal <> 'CORRESPONSALIAS' THEN [dFechaPago]
                        ELSE [dFechaPago]
                    END AS DATE
                )) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 11 AND 15 THEN '11 a 15 días'
        ELSE '16 o más días'
    END AS [Etiqueta Entrada a Pago],

/*------------------------------Entrada a Cruce -----------------------------*/


    [Fecha primera Selección],

    -- Entrada a Cruce (días hábiles)
    CASE
        WHEN TRY_CAST([Fecha Entrada/Presentación] AS DATE) IS NULL
             OR TRY_CAST([Fecha primera Selección] AS DATE) IS NULL THEN NULL
        WHEN TRY_CAST([Fecha primera Selección] AS DATE) < TRY_CAST([Fecha Entrada/Presentación] AS DATE) THEN 0
        ELSE (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha primera Selección] AS DATE)) = 'Sábado' THEN 1 ELSE 0 END)
        )
    END AS [Entrada a Cruce],

/*------------------------------ Etiqueta Entrada a Cruce -----------------------------*/

    CASE
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha primera Selección] AS DATE)) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 0 AND 1 THEN '1 día o menos'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha primera Selección] AS DATE)) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 2 AND 3 THEN '2 a 3 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha primera Selección] AS DATE)) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 4 AND 5 THEN '4 a 5 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha primera Selección] AS DATE)) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 6 AND 10 THEN '6 a 10 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha primera Selección] AS DATE)) = 'Sábado' THEN 1 ELSE 0 END)
        ) BETWEEN 11 AND 15 THEN '11 a 15 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Fecha Entrada/Presentación] AS DATE),
                TRY_CAST([Fecha primera Selección] AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha Entrada/Presentación] AS DATE)) = 'Domingo' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Fecha primera Selección] AS DATE)) = 'Sábado' THEN 1 ELSE 0 END)
        ) > 15 THEN '16 o más días'
        ELSE 'SIN DATO'
    END AS [Etiqueta entrada a Cruce],


----------------------------------

/*------------------------------ Pago Pedimento a Cruce -----------------------------*/

    CASE
        WHEN [Pedimento Fecha Pago] IS NULL OR [Pedimento Fecha Pago] = ''
        THEN 0
        ELSE (
            DATEDIFF(DAY,
                TRY_CAST([Pedimento Fecha Pago] AS DATE),
                TRY_CONVERT(DATE, [Fecha primera Selección])
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Pedimento Fecha Pago] AS DATE),
                TRY_CONVERT(DATE, [Fecha primera Selección])
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Pedimento Fecha Pago] AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATE, [Fecha primera Selección])) = 'Saturday' THEN 1 ELSE 0 END)
        )
    END AS 'Pago Pedimento a Cruce',


/*------------------------------ Pago Pedimento a Cruce Etiqueta -----------------------------*/

    CASE
        WHEN [Pedimento Fecha Pago] IS NULL OR [Pedimento Fecha Pago] = '' THEN 'Sin Dato'
        ELSE
            CASE
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Pedimento Fecha Pago] AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATE, [Fecha primera Selección])) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 0 AND 1 THEN '1 día o menos'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Pedimento Fecha Pago] AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATE, [Fecha primera Selección])) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 2 AND 3 THEN '2 a 3 días'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Pedimento Fecha Pago] AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATE, [Fecha primera Selección])) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 4 AND 5 THEN '4 a 5 días'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Pedimento Fecha Pago] AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATE, [Fecha primera Selección])) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 6 AND 10 THEN '6 a 10 días'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Pedimento Fecha Pago] AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATE, [Fecha primera Selección])) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 11 AND 15 THEN '11 a 15 días'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST([Pedimento Fecha Pago] AS DATE),
                        TRY_CONVERT(DATE, [Fecha primera Selección])
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Pedimento Fecha Pago] AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATE, [Fecha primera Selección])) = 'Saturday' THEN 1 ELSE 0 END)
                ) > 15 THEN 'más de 16 días'
                ELSE 'SIN DATO'
            END
    END AS 'Etiqueta Pago Pedimento a Cruce',


/* FUNCION DE PAGO A RUCE */

CASE
        WHEN [Pedimento Fecha Pago] IS NULL OR [Pedimento Fecha Pago] = ''
        THEN 0
        ELSE (
            DATEDIFF(DAY,
                TRY_CAST([Pedimento Fecha Pago] AS DATE),
                TRY_CONVERT(DATE, [Fecha primera Selección])
            )
            - (DATEDIFF(WEEK,
                TRY_CAST([Pedimento Fecha Pago] AS DATE),
                TRY_CONVERT(DATE, [Fecha primera Selección])
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST([Pedimento Fecha Pago] AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATE, [Fecha primera Selección])) = 'Saturday' THEN 1 ELSE 0 END)
        )
    END AS 'Pago a Cruce',


/* Funcion de cruce a entrega */


DATEDIFF(
    DAY,
    TRY_CAST([Fecha primera Selección] AS DATE),
    TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)
) AS "CRUCE A ENTREGA",

/* Funcion de etiqueta cruce a entrega */

CASE
    WHEN left([FECHA ENTREGA DE  MERCANCIA],10) IS NULL OR TRIM(left([FECHA ENTREGA DE  MERCANCIA],10)) = '' THEN 'SIN DATO'
    ELSE
        CASE
            WHEN DATEDIFF(DAY, TRY_CAST([Fecha primera Selección] AS DATE), TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)) BETWEEN 0 AND 1 THEN '1 día o menos'
            WHEN DATEDIFF(DAY, TRY_CAST([Fecha primera Selección] AS DATE), TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)) BETWEEN 2 AND 3 THEN '2 a 3 días'
            WHEN DATEDIFF(DAY, TRY_CAST([Fecha primera Selección] AS DATE), TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)) BETWEEN 4 AND 5 THEN '4 a 5 días'
            WHEN DATEDIFF(DAY, TRY_CAST([Fecha primera Selección] AS DATE), TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)) BETWEEN 6 AND 10 THEN '6 a 10 días'
            WHEN DATEDIFF(DAY, TRY_CAST([Fecha primera Selección] AS DATE), TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)) BETWEEN 11 AND 15 THEN '11 a 15 días'
            WHEN DATEDIFF(DAY, TRY_CAST([Fecha primera Selección] AS DATE), TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)) > 15 THEN 'más de 16 días'
            ELSE 'Sin dato'
        END
END AS "ETIQUETA CRUCE A ENTREGA",

----------------------------------

/*------------------------------ Entrada a Entrega -----------------------------*/


     left([FECHA ENTREGA DE  MERCANCIA],10) as [FECHA ENTREGA DE  MERCANCIA] ,

    CASE
        WHEN [FECHA ENTREGA DE  MERCANCIA] IS NULL OR TRIM([FECHA ENTREGA DE  MERCANCIA]) = ''
        THEN 0
        ELSE (
            DATEDIFF(DAY,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
        )
    END AS [Entrada a Entrega],

/*------------------------------ Etiqueta Entrada a Entrega -----------------------------*/


    CASE
        WHEN [FECHA ENTREGA DE  MERCANCIA] IS NULL OR TRIM([FECHA ENTREGA DE  MERCANCIA]) = '' THEN 'Sin Dato'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
        ) BETWEEN 0 AND 1 THEN '1 día o menos'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
        ) BETWEEN 2 AND 3 THEN '2 a 3 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
        ) BETWEEN 4 AND 5 THEN '4 a 5 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
        ) BETWEEN 6 AND 10 THEN '6 a 10 días'
        WHEN (
            DATEDIFF(DAY,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
        ) BETWEEN 11 AND 15 THEN '11 a 15 días'
        ELSE 'mas de 16 dias'
    END AS 'Etiqueta Entrada a Entrega',


/*------------------------------ Entrada a Factura -----------------------------*/

--CONVERT(VARCHAR(10),[Fechas de Cuentas de Gastos], 103) AS [FECHA TIMBRADO],

    CASE
        WHEN [Fecha Entrada/Presentación] IS NULL OR TRIM([Fecha Entrada/Presentación]) = ''
            OR CuentaG_FechaFactura IS NULL OR TRIM(CuentaG_FechaFactura) = ''
        THEN 0
        ELSE (
            DATEDIFF(DAY,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(CuentaG_FechaFactura AS DATE)
            )
            - (DATEDIFF(WEEK,
                TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                TRY_CAST(CuentaG_FechaFactura AS DATE)
            ) * 2)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
            - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(CuentaG_FechaFactura AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
        )
    END AS 'Entrada a Factura',


/*------------------------------ Etiqueta Entrada a Factura -----------------------------*/

    CASE
        WHEN [Fecha Entrada/Presentación] IS NULL OR TRIM([Fecha Entrada/Presentación]) = ''
            OR CuentaG_FechaFactura IS NULL OR TRIM(CuentaG_FechaFactura) = '' THEN 'Sin Dato'
        ELSE
            CASE
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(CuentaG_FechaFactura AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 0 AND 1 THEN '1 día o menos'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(CuentaG_FechaFactura AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 2 AND 3 THEN '2 a 3 días'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(CuentaG_FechaFactura AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 4 AND 5 THEN '4 a 5 días'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(CuentaG_FechaFactura AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 6 AND 10 THEN '6 a 10 días'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(CuentaG_FechaFactura AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
                ) BETWEEN 11 AND 15 THEN '11 a 15 días'
                WHEN (
                    DATEDIFF(DAY,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    )
                    - (DATEDIFF(WEEK,
                        TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE),
                        TRY_CAST(CuentaG_FechaFactura AS DATE)
                    ) * 2)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(SUBSTRING([Fecha Entrada/Presentación], 1, 10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
                    - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(CuentaG_FechaFactura AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
                ) > 15 THEN 'más de 16 días'
                ELSE 'SIN DATO'
            END
    END AS 'Etiqueta Entrada a Factura',




/*------------------------------ Etiqueta de fecha factura -----------------------------*/

    CuentaG_FechaFactura AS "FECHA DE FACTURACIÓN",

/* Funcion para entrega de mercancia a recibo de factura */

CASE
    WHEN [FECHA ENTREGA DE  MERCANCIA] IS NULL OR TRIM([FECHA ENTREGA DE  MERCANCIA]) = ''
        OR [FAC RECEPCION EXP. A FACTURACION] IS NULL OR TRIM([FAC RECEPCION EXP. A FACTURACION]) = ''
    THEN NULL
    ELSE (
        DATEDIFF(
            DAY,
            TRY_CAST(LEFT([FECHA ENTREGA DE  MERCANCIA],10) AS DATE),
            TRY_CAST(LEFT([FAC RECEPCION EXP. A FACTURACION],10) AS DATE)
        )
        - (DATEDIFF(
            WEEK,
            TRY_CAST(LEFT([FECHA ENTREGA DE  MERCANCIA],10) AS DATE),
            TRY_CAST(LEFT([FAC RECEPCION EXP. A FACTURACION],10) AS DATE)
        ) * 2)
        - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(LEFT([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
        - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(LEFT([FAC RECEPCION EXP. A FACTURACION],10) AS DATE)) = 'Saturday' THEN 1 ELSE 0 END)
    )
END AS "ENTREGA A ENTREGA DE FACTURA",



/* Funcion de ENTREGA A FACTURA */

(
        DATEDIFF(DAY,
            TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE),
            TRY_CAST(
                CASE
                    WHEN Sucursal = 'CORRESPONSALIAS' THEN left([FECHA ENTREGA DE  MERCANCIA],10)
                    ELSE CuentaG_FechaFactura
                END AS DATE
            )
        )
        - (DATEDIFF(WEEK,
            TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE),
            TRY_CAST(
                CASE
                    WHEN Sucursal = 'CORRESPONSALIAS' THEN left([FECHA ENTREGA DE  MERCANCIA],10)
                    ELSE CuentaG_FechaFactura
                END AS DATE
            )
        ) * 2)
        - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE)) = 'Sunday' THEN 1 ELSE 0 END)
        - (CASE WHEN DATENAME(WEEKDAY, TRY_CAST(
                CASE
                    WHEN Sucursal = 'CORRESPONSALIAS' THEN left([FECHA ENTREGA DE  MERCANCIA],10)
                    ELSE CuentaG_FechaFactura
                END AS DATE
            )) = 'Saturday' THEN 1 ELSE 0 END)
    ) AS "ENTREGA A FACTURA",

    /*------------------------------ Etiqueta días entre entrega y facturación (naturales) -----------------------------*/

CASE
WHEN left([FECHA ENTREGA DE  MERCANCIA],10) IS NULL OR TRIM(left([FECHA ENTREGA DE  MERCANCIA],10)) = '' THEN 'SIN DATO'
ELSE
CASE
WHEN DATEDIFF(DAY, TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE), TRY_CAST(CuentaG_FechaFactura AS DATE)) BETWEEN 0 AND 1 THEN '1 día o menos'
WHEN DATEDIFF(DAY, TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE), TRY_CAST(CuentaG_FechaFactura AS DATE)) BETWEEN 2 AND 3 THEN '2 a 3 días'
WHEN DATEDIFF(DAY, TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE), TRY_CAST(CuentaG_FechaFactura AS DATE)) BETWEEN 4 AND 5 THEN '4 a 5 días'
WHEN DATEDIFF(DAY, TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE), TRY_CAST(CuentaG_FechaFactura AS DATE)) BETWEEN 6 AND 10 THEN '6 a 10 días'
WHEN DATEDIFF(DAY, TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE), TRY_CAST(CuentaG_FechaFactura AS DATE)) BETWEEN 11 AND 15 THEN '11 a 15 días'
WHEN DATEDIFF(DAY, TRY_CAST(left([FECHA ENTREGA DE  MERCANCIA],10) AS DATE), TRY_CAST(CuentaG_FechaFactura AS DATE)) > 15 THEN 'más de 16 días'
ELSE 'SIN DATO'
END
END AS "ETIQUETA ENTREGA A FACTURA",

/*  FECHA QUE RECIBE FACTURA  */

CONVERT(VARCHAR(10), [FAC RECEPCION EXP. A FACTURACION], 103) AS "FECHA RECIBE FACT",

CONVERT(VARCHAR(10),[Fechas de Cuentas de Gastos], 103) AS [FECHA CUENTA DE GASTOS],


/* TIEMPO DE FACTURACION*/

CASE
    WHEN [FAC RECEPCION EXP. A FACTURACION] IS NULL
         OR TRIM([FAC RECEPCION EXP. A FACTURACION]) = ''
         OR CuentaG_FechaFactura IS NULL
         OR TRIM(CuentaG_FechaFactura) = ''
         OR TRY_CAST(LEFT([FAC RECEPCION EXP. A FACTURACION],10) AS DATE) IS NULL
         OR TRY_CAST(CuentaG_FechaFactura AS DATE) IS NULL
        THEN NULL
    ELSE (
        DATEDIFF(
            DAY,
            TRY_CAST(LEFT([FAC RECEPCION EXP. A FACTURACION],10) AS DATE),
            TRY_CAST(CuentaG_FechaFactura AS DATE)
        )
        - (DATEDIFF(
            WEEK,
            TRY_CAST(LEFT([FAC RECEPCION EXP. A FACTURACION],10) AS DATE),
            TRY_CAST(CuentaG_FechaFactura AS DATE)
        ) * 2)
        - (CASE
            WHEN DATENAME(WEEKDAY, TRY_CAST(LEFT([FAC RECEPCION EXP. A FACTURACION],10) AS DATE)) = 'Domingo' THEN 1
            ELSE 0
        END)
        - (CASE
            WHEN DATENAME(WEEKDAY, TRY_CAST(CuentaG_FechaFactura AS DATE)) = 'Sábado' THEN 1
            ELSE 0
        END)
    )
END AS "TIEMPO FACTURACION" ,
    CuentaG_FechaFactura,





/*------------------------------ etiqueta de entrega de mercancia y fecha factura -----------------------------*/

    CASE
        WHEN [FECHA ENTREGA DE  MERCANCIA] IS NULL OR TRIM([FECHA ENTREGA DE  MERCANCIA]) = '' THEN 0
        ELSE
            CASE
                WHEN TRY_CAST(SUBSTRING([FECHA ENTREGA DE  MERCANCIA], 1, 10) AS DATE) IS NULL
                     AND CuentaG_FechaFactura IS NOT NULL THEN 0
                WHEN [FECHA ENTREGA DE  MERCANCIA] IS NOT NULL
                     AND CuentaG_FechaFactura IS NOT NULL THEN 1
                ELSE 2
            END
 END AS [VERIFICADOR],


/*------------------------------ Comparacion entre tablas -----------------------------*/

    CASE
     WHEN Sucursal = 'CORRESPONSALIAS' THEN
    CASE
     WHEN TRY_CONVERT(DATE, [Corresponsalias Fecha de Pago]) < CAST(GETDATE() AS DATE) THEN 'Es anterior'
     WHEN TRY_CONVERT(DATE, [Corresponsalias Fecha de Pago]) = CAST(GETDATE() AS DATE) THEN 'Es hoy'
     WHEN TRY_CONVERT(DATE, [Corresponsalias Fecha de Pago]) > CAST(GETDATE() AS DATE) THEN 'Es posterior'
    END
  ELSE
    CASE
     WHEN TRY_CONVERT(DATE, [dFechaPago]) < CAST(GETDATE() AS DATE) THEN 'Es anterior'
     WHEN TRY_CONVERT(DATE, [dFechaPago]) = CAST(GETDATE() AS DATE) THEN 'Es hoy'
     WHEN TRY_CONVERT(DATE, [dFechaPago]) > CAST(GETDATE() AS DATE) THEN 'Es posterior'
    END
 END AS Comparacion,



----------------------------------------------------------------------------------------------------------------------------

 [Clave Pedimento],
 Ejecutivo_ABC,
 [Guia Master],
 [Guia House],
 Pedimento,
 [Tipo Operación Desc],
 MERC.MercanciaFinal AS Mercancía,
 CASE
 WHEN MERC.MercanciaFinal LIKE 'ALCOHOL%' THEN 'CSU Investigación clínica'
 ELSE 'SIN CLASIFICACION'
 END AS "TIPO MERCANCIA OK",

 '' AS "CLASIFICACIÓN DE MERCANCIA",
 [Tipo Mercancía] AS "TIPO DE MERCANCIA", --------> "FUNCION PARA SACARA SI ES PRODUCTUVI Y NO PRODUCTIVO"
 Cliente,
 [EJE UNIDAD DE NEGOCIO] AS "Unidad de negocio",
 [MOTIVO DE RETRASO],  --motivo de retraso donde esta el texto "OTRO"
 [MOTIVO DE RETRASO OTRO], -- si en el campo "MOTIVO DE RETRASO" esta el texto "OTRO" imprime lo que se tenga en este campo
 CASE
    WHEN [MOTIVO DE RETRASO] = 'OTRO' THEN [MOTIVO DE RETRASO OTRO]
    ELSE [MOTIVO DE RETRASO]
END AS "MOTIVO DE RETRASO COMPLETO", 
Ejecutivo_Tipo_Mercancia,
 [Primera Selección],
 [TRANSPORTISTA.],
 [UNIDAD RENTADA],
 [UNIDAD SUPER EXPRESS],
 RFC_Importador,
 OtrosIncPed,
 Nico,
 Mercancia_CovesSubModelo,
 [Días Credito],
 [Valor Moneda Factura ],
 [UMT DESCRIPCION],
 [Motivo de Rectificación],
 [Nombre País Origen/Destino],
 [Nombre País Vendedor/Comprador],
 [Clave de País Origen/Destino],
 [Clave de País Vendedor/Comprador]
 ,[Valor Aduana]
 ,[Importe DTA FP1]
 ,[Importe IVA 1]
 ,IGI
 ,TotalCuentadeGastos

/*------------------------------ Estado de cuenta (intervet_cuentas.sql) -----------------------------*/

 ,CASE
    WHEN CGA.CGA_CuentaDeGasto IS NOT NULL THEN 'CON ESTADO DE CUENTA'
    ELSE 'SIN ESTADO DE CUENTA'
  END AS [ESTATUS CRUCE CGA]
 ,CGA.CGA_CuentaDeGasto AS [CuentaDeGasto]
 ,CGA.CGA_EstatusCGA AS [EstatusCGA]
 ,CGA.CGA_Fecha AS [FECHA CGA]
 ,CGA.CGA_Referencia AS [REFERENCIA CGA]
 ,CGA.CGA_Pedimento AS [PEDIMENTO CGA]
 ,CGA.CGA_Mercancia AS [MERCANCIA CGA]
 ,CGA.CGA_Pedido AS [PEDIDO]
 ,CGA.CGA_Observaciones AS [OBSERVACIONES CGA]
 ,CGA.CGA_Operacion AS [OPERACION]
 ,CGA.CGA_Cliente AS [CLIENTE CGA]
 ,CGA.CGA_PagosTerceros AS [PAGOS TERCEROS]
 ,CGA.CGA_Honorarios AS [HONORARIOS ABC]
 ,CGA.CGA_Complementarios AS [COMPLEMENTARIOS]
 ,CGA.CGA_IVA AS [IVA CGA]
 ,CGA.CGA_Anticipo AS [ANTICIPO]
 ,CGA.CGA_TotalFactura AS [TOTAL FACTURA]
 ,CGA.CGA_PagoParcial AS [PAGO PARCIAL]
 ,CGA.CGA_SaldoFactura AS [SALDO FACTURA]
 ,CGA.CGA_UUID AS [UUID]
 ,CGA.CGA_DiasCredito AS [Días Credito CGA]
/*------------------------------ Conexion con la tabla -----------------------------*/

FROM (
    SELECT
        *,
        TRY_CAST([Fecha Entrada/Presentación] AS DATE) AS FechaEntradaDate,
        CASE
            WHEN Sucursal = 'CORRESPONSALIAS' THEN TRY_CAST([Corresponsalias Fecha de Pago] AS DATE)
            ELSE TRY_CAST([dFechaPago] AS DATE)
        END AS FechaPagoOperativa,
        REPLACE(TRIM(Referencia), '/', '') AS ReferenciaNormalizada,
        RIGHT(TRIM(CAST(Pedimento AS VARCHAR(20))), 7) AS PedimentoUltimos7,
        /* Misma formula que el campo 'Cuenta de gastos', normalizada para el cruce */
        UPPER(REPLACE(CONCAT(SUBSTRING(TRIM([CuentaG_Folio_Num_Factura]),1,1),TRIM([CuentaG_FolioFactura])), ' ', '')) AS CuentaGastosNormalizada
    FROM [SIR].[Admin].[SIR_VT_Sabana_Pedimento_ABC]
) AS SABANA
LEFT JOIN (
    SELECT
        REPLACE(TRIM(Referencia), '/', '') AS ReferenciaNormalizada,
        RIGHT(TRIM(CAST(Pedimento AS VARCHAR(20))), 7) AS PedimentoUltimos7,
        MAX(CAST(NULLIF(TRIM(Mercancia), '') AS NVARCHAR(4000))) AS MercanciaRefPedimento
    FROM [SIR].[Admin].[ADMIN_VT_CGReferenciaEntrada]
    GROUP BY
        REPLACE(TRIM(Referencia), '/', ''),
        RIGHT(TRIM(CAST(Pedimento AS VARCHAR(20))), 7)
) AS REF_E
    ON SABANA.ReferenciaNormalizada = REF_E.ReferenciaNormalizada
    AND SABANA.PedimentoUltimos7 = REF_E.PedimentoUltimos7
LEFT JOIN (
    SELECT
        REPLACE(TRIM(Referencia), '/', '') AS ReferenciaNormalizada,
        MAX(CAST(NULLIF(TRIM(Mercancia), '') AS NVARCHAR(4000))) AS MercanciaRefReferencia
    FROM [SIR].[Admin].[ADMIN_VT_CGReferenciaEntrada]
    GROUP BY REPLACE(TRIM(Referencia), '/', '')
) AS REF_E2
    ON SABANA.ReferenciaNormalizada = REF_E2.ReferenciaNormalizada
OUTER APPLY (
    SELECT
        CAST(CASE
            WHEN SABANA.Sucursal = 'CORRESPONSALIAS'
                 OR SABANA.Referencia LIKE '%LT%'
                 or SABANA.Referencia LIKE '%NLS%'
                 OR SABANA.Referencia LIKE '%MNS%'
                THEN COALESCE(
                    REF_E.MercanciaRefPedimento,
                    CAST(NULLIF(TRIM(SABANA.Mercancía), '') AS NVARCHAR(4000)),
                    REF_E2.MercanciaRefReferencia
                )
            ELSE COALESCE(
                CAST(NULLIF(TRIM(SABANA.Mercancía), '') AS NVARCHAR(4000)),
                REF_E.MercanciaRefPedimento,
                REF_E2.MercanciaRefReferencia
            )
        END AS NVARCHAR(4000)) AS MercanciaFinal
) AS MERC

/*------------------------------ Union con estado de cuenta (intervet_cuentas.sql) -----------------------------*/
/* Referencia = principal, Cuenta de gastos = separa las cuentas de una misma referencia */
LEFT JOIN (
    SELECT
        UPPER(REPLACE(TRIM(Referencia), '/', '')) AS CGA_ReferenciaNormalizada,
        UPPER(REPLACE(TRIM(CAST([CuentaDeGasto] AS VARCHAR(50))), ' ', '')) AS CGA_CuentaGastosNormalizada,
        [CuentaDeGasto] AS CGA_CuentaDeGasto,
        EstatusCGA AS CGA_EstatusCGA,
        CASE
            WHEN [Fecha] IS NOT NULL THEN CAST([Fecha] AS DATE)
            ELSE NULL
        END AS CGA_Fecha,
        Referencia AS CGA_Referencia,
        Pedimento AS CGA_Pedimento,
        DescripcionMercancia AS CGA_Mercancia,
        Pedido AS CGA_Pedido,
        sObservacionesCGA AS CGA_Observaciones,
        Operacion AS CGA_Operacion,
        Cliente AS CGA_Cliente,
        PagosHechosME AS CGA_PagosTerceros,
        HonorariosME AS CGA_Honorarios,
        ComplementariosME AS CGA_Complementarios,
        IVA AS CGA_IVA,
        AnticiposME AS CGA_Anticipo,
        TotalME AS CGA_TotalFactura,
        LiquidacionME AS CGA_PagoParcial,
        SaldoME AS CGA_SaldoFactura,
        UUID AS CGA_UUID,
        [DiasCred] AS CGA_DiasCredito
    FROM [SIR].[Admin].[SIR_VT_CCEstadoDeCuenta]
    WHERE Cliente LIKE '%INTERVET%'
      AND TotalME > 0
) AS CGA
    ON UPPER(SABANA.ReferenciaNormalizada) = CGA.CGA_ReferenciaNormalizada
    AND SABANA.CuentaGastosNormalizada = CGA.CGA_CuentaGastosNormalizada

WHERE --Referencia = 'VER-24-1105'
Cliente like ('%INTERVET%')
--[Cliente] like '%BOEH%'
--AND [Referencia] LIKE '%R1%'

AND SABANA.FechaPagoOperativa >= '2026-01-01'
AND SABANA.FechaPagoOperativa < '2026-09-01'
--and [Sucursal] = 'CORRESPONSALIAS'