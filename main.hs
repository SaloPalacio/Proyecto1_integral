{-# LANGUAGE OverloadedStrings #-}

import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C
import Data.Bits (testBit)
import Control.Monad (forM_)

-- 1. Cargar y parsear el archivo PBM P4
-- La cabecera tiene el formato: P4 \n # comentario \n ancho alto \n [datos binarios]
parsePBM :: B.ByteString -> (Int, Int, B.ByteString)
parsePBM bs = 
    let (p4, rest1) = C.break (== '\n') bs
        rest1' = B.tail rest1 
        (comment, rest2) = C.break (== '\n') rest1'
        rest2' = B.tail rest2
        (dims, imgDataRaw) = C.break (== '\n') rest2'
        [wStr, hStr] = C.words dims
        w = read (C.unpack wStr) :: Int
        h = read (C.unpack hStr) :: Int
        imgData = B.tail imgDataRaw
    in (w, h, imgData)

-- 2. Acceso a píxeles individuales
-- En PBM P4, un byte contiene información de hasta 8 píxeles.
getPixel :: B.ByteString -> Int -> Int -> Int -> Bool
getPixel imgData width x y =
    let bytesPerRow = (width + 7) `div` 8
        byteIdx = y * bytesPerRow + (x `div` 8)
        bitIdx = 7 - (x `mod` 8) -- El bit más significativo es el píxel más a la izquierda
        byte = B.index imgData byteIdx
    in testBit byte bitIdx

-- 3. Construir la función discreta f(x)
-- Cuenta los píxeles negros (True) consecutivos desde la parte inferior (y = height - 1) hacia arriba.
f :: B.ByteString -> Int -> Int -> Int -> Int
f imgData width height x =
    let column = [getPixel imgData width x y | y <- reverse [0 .. height - 1]]
    in length $ takeWhile (== True) column

main :: IO ()
main = do
    -- Leer el archivo en formato binario estricto
    bs <- B.readFile "curva_binaria_P4.pbm"
    let (w, h, imgData) = parsePBM bs

    -- 4. Construir la estructura de alturas M = [f(0), f(1), ..., f(n-1)]
    -- Esto demuestra la transformación funcional del dominio aplicando f
    let domain = [0 .. w - 1]
    let m = map (f imgData w h) domain
    
    -- 5. Calcular el área usando la suma de Riemann
    let area = sum m

    putStrLn $ "Imagen: " ++ show w ++ " x " ++ show h ++ " pixeles"
    putStrLn $ "Area = " ++ show area ++ " pixeles cuadrados"

    -- 6 y 7. Visualización de la imagen y la función de altura en consola
    -- Estrategia de compactación: Agrupamos columnas tomando la altura máxima del bloque
    -- y escalamos verticalmente dividiendo las alturas.
    putStrLn "\nVECTOR DE ALTURAS M[x] = f(x)"
    let consoleWidth = 90
        consoleHeight = 15
        scaleX = w `div` consoleWidth
        scaleY = maximum m `div` consoleHeight
        
        -- Muestreo espacial para reducir el ancho de la curva
        scaledM = [maximum (take scaleX (drop (i * scaleX) m)) | i <- [0 .. consoleWidth - 1]]

    -- Dibujar la gráfica en consola de arriba hacia abajo
    forM_ (reverse [1 .. consoleHeight]) $ \yLevel -> do
        let threshold = yLevel * scaleY
            line = map (\hVal -> if hVal >= threshold then '█' else ' ') scaledM
        putStrLn line

    -- 8. Mostrar valores de muestra
    putStrLn "\nALGUNOS VALORES x_i -> f(x_i)"
    let sampleIndices = [0, 62, 125, 188, 251, 314, 377, 440, 503, 566]
    forM_ sampleIndices $ \xi -> do
        -- Protegemos contra índices fuera de rango si la imagen fuera más pequeña
        if xi < w then
            putStrLn $ "x_" ++ show xi ++ " = " ++ show xi ++ "\t-> f(x_" ++ show xi ++ ") = " ++ show (m !! xi) ++ " pixeles"
        else return ()

    putStrLn "\nCada columna tiene base = 1 pixel"
    putStrLn "Area = suma de f(x_i)"
    putStrLn $ "Area = " ++ show area ++ " pixeles cuadrados"